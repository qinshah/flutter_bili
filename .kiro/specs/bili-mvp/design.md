# 设计文档

## 概述

flutter_bili 是一个基于 Flutter 的哔哩哔哩客户端 MVP，聚焦两个核心功能：**扫码登录**与**视频播放**。项目采用 provider 进行状态管理，dio 作为 HTTP 客户端，media_kit 负责视频解码与渲染，支持手机端与 PC 端的自适应布局。

参考实现来自 PiliPlus 项目，复用其 API 端点定义、Wbi/AppSign 签名机制、DASH 数据模型及重试拦截器的设计思路。

---

## 架构

整体采用分层架构：

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                         │
│  LoginPage / VideoDetailPage / HomeScaffold         │
│  (LayoutBuilder + MediaQuery 响应式布局)              │
├─────────────────────────────────────────────────────┤
│                  State Layer                        │
│  AuthProvider / VideoProvider / PlatformProvider    │
│  (provider 包，ChangeNotifier)                       │
├─────────────────────────────────────────────────────┤
│                 Service Layer                       │
│  AuthService / VideoService                         │
│  (业务逻辑，协调 HTTP 与本地存储)                       │
├─────────────────────────────────────────────────────┤
│                  HTTP Layer                         │
│  Request (dio) / RetryInterceptor / AuthInterceptor │
│  WbiSign / AppSign                                  │
├─────────────────────────────────────────────────────┤
│               Persistence Layer                     │
│  hive_ce + hive_ce_flutter (凭证、Wbi Key 缓存)     │
└─────────────────────────────────────────────────────┘
```

### 关键设计决策

- **布局断点**：以 `LayoutBuilder`/`MediaQuery` 获取的宽度为准，`>= 800px` 为宽屏，`< 800px` 为窄屏。`OS.isPCOS` 仅用于注入平台信息，不作为布局判断依据。
- **window_manager 启用条件**：使用 `Platform.isWindows || Platform.isLinux || Platform.isMacOS`，而非 `OS.isPCOS`，以避免鸿蒙 PC 模式误触发。
- **签名机制**：Web 端接口（如 `/x/player/wbi/playurl`、`/x/web-interface/view`）使用 Wbi 签名；TV 端接口（如 `/x/passport-tv-login/qrcode/auth_code`）使用 AppSign。
- **视频流格式**：固定使用 DASH（`fnval=4048`），由 media_kit 负责解码，不支持 FLV 降级。

---

## 组件与接口

### HTTP 层

```dart
// lib/http/request.dart
class Request {
  static late final Dio dio;
  factory Request() => _instance;
  // 初始化：baseUrl=https://api.bilibili.com，超时 10s，RetryInterceptor，AuthInterceptor
  Request._internal();
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, Options? options});
  Future<Response> post(String url, {Object? data, Options? options});
}

// lib/http/retry_interceptor.dart
class RetryInterceptor extends Interceptor {
  // 最多重试 2 次，间隔 1 秒
  // 仅对 connectionError / connectionTimeout / sendTimeout / unknown 重试
}

// lib/http/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  // App 端接口：在 queryParameters 中注入 access_key
  // Web 端接口：在 Cookie 中注入 SESSDATA
  // 检测到 401 或业务码登录失效时，清除凭证并跳转登录页
}
```

### 签名工具

```dart
// lib/utils/wbi_sign.dart
abstract final class WbiSign {
  // 从 /x/web-interface/nav 获取 img_url/sub_url，生成 mixinKey
  // 缓存当天的 mixinKey，避免重复请求
  static Future<Map<String, Object>> makSign(Map<String, Object> params);
}

// lib/utils/app_sign.dart
abstract final class AppSign {
  // 注入 appkey、ts，按 key 排序后 MD5 签名
  static void appSign(Map<String, dynamic> params);
}
```

### 登录模块

```dart
// lib/http/login_http.dart
abstract final class LoginHttp {
  // POST /x/passport-tv-login/qrcode/auth_code (AppSign)
  static Future<LoadingState<({String authCode, String url})>> getAuthCode();
  // POST /x/passport-tv-login/qrcode/poll (AppSign)
  static Future<Map> codePoll(String authCode);
}

// lib/services/auth_service.dart
class AuthService extends ChangeNotifier {
  bool get isLogin;
  String? get accessKey;
  String? get sessdata;
  Future<void> loadFromStorage();
  Future<void> saveCredentials({required String accessKey, required String refreshToken, required String sessdata});
  Future<void> clearCredentials();
}

// lib/widgets/qr_code_poller.dart
class QrCodePoller {
  // 每 3 秒轮询一次 codePoll
  // code==0 → 通知 AuthService 保存凭证
  // code==86038 → 停止轮询，通知 UI 显示过期提示
  // 网络错误 → 停止轮询，通知 UI 显示错误提示
  void start(String authCode);
  void stop();
  void dispose();
}
```

### 视频模块

```dart
// lib/http/video_http.dart
abstract final class VideoHttp {
  // GET /x/web-interface/view?bvid=xxx
  static Future<LoadingState<VideoDetailData>> videoDetail({required String bvid});
  // GET /x/player/wbi/playurl (Wbi 签名, fnval=4048)
  static Future<LoadingState<PlayUrlModel>> videoUrl({required String bvid, required int cid, int? qn});
  // POST /x/click-interface/web/heartbeat (每 15 秒)
  static Future<void> heartBeat({required String bvid, required int cid, required int progress});
}

// lib/services/video_service.dart
class VideoService extends ChangeNotifier {
  VideoDetailData? get detail;
  PlayUrlModel? get playUrl;
  int get selectedPage;
  Future<void> loadDetail(String bvid);
  Future<void> loadPlayUrl(String bvid, int cid, {int? qn});
  void selectPage(int index);
  int selectBestQuality(List<int> availableQn);
}
```

### 布局组件

```dart
// lib/widgets/adaptive_scaffold.dart
class AdaptiveScaffold extends StatelessWidget {
  // width >= 800: NavigationRail（左侧）+ 内容区
  // width < 800:  BottomNavigationBar + 内容区
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 800;
      // ...
    });
  }
}
```

---

## 数据模型

### 凭证模型

```dart
// lib/models/auth/credentials.dart
@HiveType(typeId: 0)
class Credentials extends HiveObject {
  @HiveField(0) final String accessKey;
  @HiveField(1) final String refreshToken;
  @HiveField(2) final String sessdata;
  @HiveField(3) final String csrf;
  @HiveField(4) final DateTime expiresAt;
}
```

### 视频详情模型

```dart
// lib/models/video/video_detail.dart
class VideoDetailData {
  final String bvid;
  final int aid;
  final String title;
  final String pic;
  final String desc;
  final OwnerInfo owner;
  final StatInfo stat;
  final List<PageInfo> pages;
}

class OwnerInfo { final int mid; final String name; final String face; }
class StatInfo  { final int view; final int like; final int coin; final int favorite; }
class PageInfo  { final int cid; final int page; final String part; final int duration; }
```

### 播放地址模型

复用 PiliPlus 的 `PlayUrlModel` / `Dash` / `VideoItem` / `AudioItem`。关键字段：
- `dash.video`: `List<VideoItem>`，`id` 对应画质码（116=1080P60, 80=1080P, 64=720P, 32=480P, 16=360P）
- `acceptQuality`: `List<int>`，当前可用画质列表

### 画质枚举

```dart
// lib/models/video/video_quality.dart
enum VideoQuality {
  q1080p60(116, '1080P60'),
  q1080p(80,  '1080P'),
  q720p(64,   '720P'),
  q480p(32,   '480P'),
  q360p(16,   '360P');

  const VideoQuality(this.code, this.label);
  final int code;
  final String label;
  static const List<int> priorityOrder = [116, 80, 64, 32, 16];
}
```

### 加载状态

```dart
// lib/http/loading_state.dart
sealed class LoadingState<T> {}
class Success<T> extends LoadingState<T> { final T response; }
class Error<T>   extends LoadingState<T> { final String? message; }
```

---

## 正确性属性

*属性（Property）是在系统所有有效执行中都应成立的特征或行为——本质上是对系统应做什么的形式化陈述。属性是人类可读规范与机器可验证正确性保证之间的桥梁。*

### 属性 1：布局断点决策

*对于任意* 界面宽度值，布局决策函数应满足：宽度 >= 800px 时返回宽屏布局类型，宽度 < 800px 时返回窄屏布局类型。

**验证：需求 1.9、3.9、5.3、5.4**

### 属性 2：凭证持久化 Round-Trip

*对于任意* 合法的 access_key、refresh_token 和 sessdata 组合，调用 `saveCredentials` 写入 Hive Box 后再调用 `loadCredentials`，应能读取到完全相同的凭证值。

**验证：需求 1.3、1.8**

### 属性 3：轮询间隔

*对于任意* 正在运行的 QrCodePoller 实例，相邻两次 `codePoll` 调用之间的时间间隔应不小于 3 秒。

**验证：需求 1.2**

### 属性 4：轮询停止条件

*对于任意* 返回 code == 86038 或网络错误的 `codePoll` 响应，QrCodePoller 在收到该响应后应不再发起新的轮询请求。

**验证：需求 1.4、1.6**

### 属性 5：刷新后 authCode 更新

*对于任意* 已有 authCode，用户触发刷新操作后，新生成的 authCode 应与旧值不同（假设接口正常返回）。

**验证：需求 1.5**

### 属性 6：视频详情字段完整性

*对于任意* 有效的 VideoDetailData 实例，其渲染结果应包含 title、pic、owner.name、owner.face、stat.view、stat.like、desc 全部字段的非空展示。

**验证：需求 2.2**

### 属性 7：多分 P 默认选中第一 P

*对于任意* pages 列表长度大于 1 的视频，VideoService 初始化后 `selectedPage` 应为 0，且使用的 CID 应等于 `pages[0].cid`。

**验证：需求 2.3**

### 属性 8：分 P 切换使用正确 CID

*对于任意* 分 P 索引 i，调用 `selectPage(i)` 后，后续 `loadPlayUrl` 请求中使用的 cid 应等于 `pages[i].cid`。

**验证：需求 2.4**

### 属性 9：播放地址请求携带 fnval=4048

*对于任意* 视频播放地址请求，请求参数中 `fnval` 的值应等于 4048。

**验证：需求 3.1**

### 属性 10：画质选择优先级

*对于任意* 可用画质列表（acceptQuality），`selectBestQuality` 函数应返回列表中优先级最高的画质码（优先顺序：116 > 80 > 64 > 32 > 16）。

**验证：需求 3.3**

### 属性 11：错误码映射

*对于任意* 播放地址接口错误码，错误映射函数应返回非空的错误描述字符串；特别地，-404 应映射到包含"不存在"或"已被删除"的字符串，87008 应映射到包含"专属"或"充电"的字符串。

**验证：需求 3.6、3.7**

### 属性 12：认证信息自动注入

*对于任意* 需要登录的接口请求，AuthInterceptor 处理后的请求应在 queryParameters 中包含非空的 `access_key`（App 端）或在 Cookie 中包含非空的 `SESSDATA`（Web 端）。

**验证：需求 4.2**

### 属性 13：重试次数上限

*对于任意* 触发重试条件的网络错误，RetryInterceptor 最多重试 2 次，总请求次数不超过 3 次。

**验证：需求 4.3**

### 属性 14：Wbi 签名参数完整性

*对于任意* 输入参数 map，经过 `WbiSign.makSign` 处理后，结果 map 应包含 `w_rid` 和 `wts` 两个额外字段，且原有参数均被保留。

**验证：需求 4.4**

### 属性 15：登录失效时清除凭证

*对于任意* 返回 HTTP 401 或登录失效业务码的响应，AuthInterceptor 处理后本地存储中的凭证应被清除（`loadFromStorage` 返回 null）。

**验证：需求 4.5**

---

## 持久化层设计

使用 `hive_ce` + `hive_ce_flutter` 作为本地存储方案，替代 SharedPreferences，提供类型安全的 KV 存储。

### Box 划分

| Box 名称 | 类型 | 用途 |
|----------|------|------|
| `credentials` | `Box<Credentials>` | 存储登录凭证，key 固定为 `'main'` |
| `localCache` | `Box<dynamic>` | 存储 Wbi mixinKey、时间戳等缓存数据 |

### 初始化

```dart
// lib/core/app_storage.dart
abstract final class AppStorage {
  static late Box<Credentials> credentials;
  static late Box<dynamic> cache;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CredentialsAdapter()); // 由 hive_ce_generator 生成
    credentials = await Hive.openBox<Credentials>('credentials');
    cache       = await Hive.openBox<dynamic>('cache');
  }
}
```

### 凭证读写

```dart
// AuthService 内部使用
Future<void> saveCredentials(Credentials cred) async {
  await AppStorage.credentials.put('main', cred);
}

Credentials? loadCredentials() {
  return AppStorage.credentials.get('main');
}

Future<void> clearCredentials() async {
  await AppStorage.credentials.delete('main');
}
```

### Wbi Key 缓存

```dart
// WbiSign 内部使用 AppStorage.cache
// key: 'mixinKey'     → String
// key: 'wbiTimestamp' → int (millisecondsSinceEpoch)
// 每天刷新一次（比较 day 是否相同）
```

---

## 错误处理

| 场景 | 处理方式 |
|------|----------|
| 二维码过期（86038） | 停止轮询，UI 显示"二维码已过期，请刷新"，提供刷新按钮 |
| 网络请求失败 | RetryInterceptor 自动重试 2 次；仍失败则 UI 显示错误信息 |
| 视频不存在（-404） | UI 显示"视频不存在或已被删除" |
| 专属视频（87008） | UI 显示"该视频为专属视频，可能需要充电观看" |
| 登录态失效（401） | 清除本地凭证，跳转登录页 |
| 播放失败（网络中断） | VideoPlayer 显示加载失败提示，提供重试按钮 |
| 视频详情接口非 0 错误码 | UI 显示接口返回的 message 字段 |

所有 HTTP 响应通过 `LoadingState<T>` 封装，UI 层通过 `switch` 模式匹配处理 `Success` 和 `Error` 两种状态。

---

## 测试策略

### 双轨测试方法

- **单元测试**：验证具体示例、边界条件和错误处理路径
- **属性测试**：验证对所有输入都成立的普遍性质，两者互补

### 属性测试配置

使用 [fast_check](https://pub.dev/packages/fast_check)（Dart 属性测试库）。每个属性测试最少运行 100 次迭代。

每个属性测试必须包含注释标注对应的设计属性，格式：

```
// Feature: bili-mvp, Property N: <属性描述>
```

示例：

```dart
// Feature: bili-mvp, Property 1: 布局断点决策
test('layout breakpoint decision', () {
  fc.assert(
    fc.property(fc.double(min: 0, max: 2000), (width) {
      final layout = resolveLayout(width);
      if (width >= 800) {
        expect(layout, LayoutType.wide);
      } else {
        expect(layout, LayoutType.narrow);
      }
    }),
    numRuns: 100,
  );
});
```

### 单元测试重点

- `WbiSign.getMixinKey`：验证字符顺序打乱逻辑
- `AppSign.appSign`：验证签名参数注入与 MD5 计算
- `VideoService.selectBestQuality`：验证画质优先级选择
- `AuthService.saveCredentials` / `loadFromStorage`：验证持久化 round-trip
- 错误码映射函数：验证 -404、87008 等特定错误码的文案

### 属性测试覆盖

| 属性编号 | 测试描述 | 生成器 |
|----------|----------|--------|
| 属性 1 | 布局断点决策 | `fc.double(min: 0, max: 2000)` |
| 属性 2 | 凭证持久化 round-trip | `fc.record({accessKey: fc.string(), ...})` |
| 属性 3 | 轮询间隔 >= 3s | `fc.integer(min: 1, max: 10)`（轮询次数） |
| 属性 4 | 轮询停止条件 | `fc.constantFrom(86038, -1)` |
| 属性 9 | fnval=4048 | `fc.record({bvid: fc.string(), cid: fc.integer()})` |
| 属性 10 | 画质优先级选择 | `fc.subarray([116, 80, 64, 32, 16])` |
| 属性 11 | 错误码映射非空 | `fc.integer(min: -10000, max: 100000)` |
| 属性 13 | 重试次数 <= 3 | `fc.integer(min: 1, max: 5)`（失败次数） |
| 属性 14 | Wbi 签名参数完整性 | `fc.dictionary(fc.string(), fc.string())` |
