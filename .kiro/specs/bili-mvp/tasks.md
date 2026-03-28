# 实现计划

## 任务列表

- [x] 1. 基础设施：数据模型与持久化层
  - [x] 1.1 创建 `LoadingState<T>` 密封类（`lib/http/loading_state.dart`）
  - [x] 1.2 创建 `Credentials` Hive 模型（`lib/models/auth/credentials.dart`），包含 `@HiveType`/`@HiveField` 注解
  - [x] 1.3 创建 `VideoDetailData`、`OwnerInfo`、`StatInfo`、`PageInfo` 数据类（`lib/models/video/video_detail.dart`）
  - [x] 1.4 创建 `VideoQuality` 枚举及 `priorityOrder`（`lib/models/video/video_quality.dart`）
  - [x] 1.5 复制/适配 PiliPlus 的 `PlayUrlModel`、`Dash`、`VideoItem`、`AudioItem`（`lib/models/video/play_url_model.dart`）
  - [x] 1.6 创建 `AppStorage` 初始化类（`lib/core/app_storage.dart`），注册 Hive Adapter，打开 `credentials` 与 `cache` Box
  - [x] 1.7 运行 `build_runner` 生成 `CredentialsAdapter`

- [x] 2. HTTP 层：签名工具与拦截器
  - [x] 2.1 实现 `AppSign`（`lib/utils/app_sign.dart`）：注入 appkey/ts，按 key 排序后 MD5 签名
  - [x] 2.2 实现 `WbiSign`（`lib/utils/wbi_sign.dart`）：从 `/x/web-interface/nav` 获取 img_url/sub_url，生成并缓存当天 mixinKey，提供 `makSign` 方法
  - [x] 2.3 实现 `RetryInterceptor`（`lib/http/retry_interceptor.dart`）：最多重试 2 次，间隔 1 秒，仅对 connectionError/connectionTimeout/sendTimeout/unknown 重试
  - [x] 2.4 实现 `AuthInterceptor`（`lib/http/auth_interceptor.dart`）：App 端注入 `access_key`，Web 端注入 `SESSDATA` Cookie；检测 401 或登录失效业务码时清除凭证并跳转登录页
  - [x] 2.5 实现 `Request` 单例（`lib/http/request.dart`）：baseUrl=`https://api.bilibili.com`，超时 10s，挂载 `RetryInterceptor` 与 `AuthInterceptor`

- [x] 3. 服务层：AuthService 与 VideoService
  - [x] 3.1 实现 `AuthService`（`lib/services/auth_service.dart`）：`ChangeNotifier`，提供 `isLogin`/`accessKey`/`sessdata`，实现 `loadFromStorage`/`saveCredentials`/`clearCredentials`
  - [x] 3.2 实现 `VideoService`（`lib/services/video_service.dart`）：`ChangeNotifier`，提供 `detail`/`playUrl`/`selectedPage`，实现 `loadDetail`/`loadPlayUrl`/`selectPage`/`selectBestQuality`

- [x] 4. HTTP 接口层：LoginHttp 与 VideoHttp
  - [x] 4.1 实现 `LoginHttp`（`lib/http/login_http.dart`）：`getAuthCode`（POST `/x/passport-tv-login/qrcode/auth_code`，AppSign）、`codePoll`（POST `/x/passport-tv-login/qrcode/poll`，AppSign）
  - [x] 4.2 实现 `VideoHttp`（`lib/http/video_http.dart`）：`videoDetail`（GET `/x/web-interface/view`）、`videoUrl`（GET `/x/player/wbi/playurl`，Wbi 签名，`fnval=4048`）、`heartBeat`（POST `/x/click-interface/web/heartbeat`）

- [x] 5. 登录模块：QrCodePoller 与 LoginPage
  - [x] 5.1 实现 `QrCodePoller`（`lib/widgets/qr_code_poller.dart`）：每 3 秒轮询 `codePoll`；code==0 时通知 `AuthService` 保存凭证；code==86038 时停止轮询并回调过期；网络错误时停止轮询并回调错误
  - [x] 5.2 实现 `LoginPage`（`lib/pages/login/login_page.dart`）：调用 `getAuthCode` 渲染二维码（`pretty_qr_code`）；启动 `QrCodePoller`；处理过期/错误提示与刷新按钮；登录成功后跳转首页
  - [x] 5.3 根据 `LayoutBuilder` 宽度决策：>= 800px 以居中弹窗展示二维码，< 800px 以全屏页面展示

- [x] 6. 视频详情与播放模块
  - [x] 6.1 实现 `VideoDetailPage`（`lib/pages/video/video_detail_page.dart`）：调用 `VideoService.loadDetail` 与 `loadPlayUrl`；展示标题、封面、UP 主信息、播放量、点赞数、简介；多分 P 时展示分 P 列表并支持切换
  - [x] 6.2 集成 `media_kit` 播放器：加载 DASH 视频流，提供播放/暂停、进度拖拽、全屏切换、画质切换控件
  - [x] 6.3 实现心跳上报：视频播放时每 15 秒调用 `VideoHttp.heartBeat`
  - [x] 6.4 实现错误码展示：-404 → "视频不存在或已被删除"；87008 → "该视频为专属视频，可能需要充电观看"；网络中断 → 加载失败提示 + 重试按钮
  - [x] 6.5 根据 `LayoutBuilder` 宽度决策布局：>= 800px 宽屏横向布局（左侧播放器+信息，右侧推荐列表），< 800px 窄屏竖向布局

- [x] 7. 自适应导航脚手架与应用入口
  - [x] 7.1 实现 `AdaptiveScaffold`（`lib/widgets/adaptive_scaffold.dart`）：>= 800px 使用 `NavigationRail`（左侧），< 800px 使用 `BottomNavigationBar`
  - [x] 7.2 实现 `HomeScaffold`（`lib/pages/home/home_scaffold.dart`）：集成 `AdaptiveScaffold`，包含首页、视频入口等导航项；登录成功后展示用户头像与昵称
  - [x] 7.3 更新 `main.dart`：初始化 `AppStorage`、`MediaKit`；在 `window_manager` 启用条件（`Platform.isWindows || Platform.isLinux || Platform.isMacOS`）下初始化窗口管理；注入 `MultiProvider`（`AuthService`、`VideoService`）；根据 `AuthService.isLogin` 决定初始路由（登录页或首页）

- [x] 8. 单元测试
  - [x] 8.1 测试 `AppSign.appSign`：验证签名参数注入与 MD5 计算正确性
  - [x] 8.2 测试 `WbiSign.getMixinKey`：验证字符顺序打乱逻辑
  - [x] 8.3 测试 `VideoService.selectBestQuality`：验证画质优先级选择（含边界：空列表、单元素、全部可用）
  - [x] 8.4 测试 `AuthService` 凭证持久化：`saveCredentials` 后 `loadFromStorage` 返回相同值；`clearCredentials` 后返回 null
  - [x] 8.5 测试错误码映射函数：-404 映射包含"不存在"或"已被删除"；87008 映射包含"专属"或"充电"

- [x] 9. 属性测试（fast_check）
  - [x] 9.1 属性 1：布局断点决策 —— 对任意宽度值，>= 800 返回宽屏，< 800 返回窄屏（验证：需求 1.9、3.9、5.3、5.4）
  - [x] 9.2 属性 2：凭证持久化 Round-Trip —— 对任意合法凭证，save 后 load 返回相同值（验证：需求 1.3、1.8）
  - [x] 9.3 属性 3：轮询间隔 —— 相邻两次 `codePoll` 调用间隔 >= 3 秒（验证：需求 1.2）
  - [x] 9.4 属性 4：轮询停止条件 —— code==86038 或网络错误后不再发起新轮询（验证：需求 1.4、1.6）
  - [x] 9.5 属性 9：fnval=4048 —— 任意播放地址请求参数中 `fnval` 等于 4048（验证：需求 3.1）
  - [x] 9.6 属性 10：画质优先级选择 —— 对任意可用画质子集，`selectBestQuality` 返回优先级最高的画质码（验证：需求 3.3）
  - [x] 9.7 属性 11：错误码映射非空 —— 对任意错误码，映射函数返回非空字符串（验证：需求 3.6、3.7）
  - [x] 9.8 属性 13：重试次数上限 —— 触发重试条件时总请求次数不超过 3 次（验证：需求 4.3）
  - [x] 9.9 属性 14：Wbi 签名参数完整性 —— 经 `WbiSign.makSign` 处理后结果包含 `w_rid` 和 `wts`，且原有参数均被保留（验证：需求 4.4）
