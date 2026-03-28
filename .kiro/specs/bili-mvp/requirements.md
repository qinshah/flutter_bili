# 需求文档

## 简介

flutter_bili 是一个基于 Flutter 开发的哔哩哔哩客户端 MVP 版本，旨在验证 Flutter 的生产可行性，同时提供与官方哔哩哔哩应用体验一致甚至更优的使用体验。MVP 阶段聚焦两个核心功能：**扫码登录**与**视频播放**，支持手机端与 PC 端的自适应布局，一次开发多端部署。

网络请求接口与数据模型参考 PiliPlus 项目（`/Users/qshh/Desktop/Code/FTH/PiliPlus`），状态管理使用 provider，平台判断使用 `OS.isPCOS`、`OS.isMobileOS`、`OS.isHarmony` 等。

---

## 词汇表

- **App**：flutter_bili 客户端应用
- **AuthService**：负责登录状态管理与 Token 持久化的服务
- **QrCodePoller**：负责轮询二维码扫描状态的组件
- **VideoPlayer**：负责视频流解码与渲染的播放器组件
- **VideoService**：负责获取视频信息与播放地址的服务
- **OS**：来自 `os_type` 包的平台判断工具类
- **Provider**：Flutter 状态管理库，用于全局状态共享
- **AccessKey**：哔哩哔哩 App 端登录凭证
- **AuthCode**：TV 端扫码登录的授权码
- **BVid**：哔哩哔哩视频的 BV 号标识
- **CID**：哔哩哔哩视频分 P 的唯一标识
- **DASH**：自适应流媒体协议，用于视频分段传输
- **Wbi 签名**：哔哩哔哩 Web 端接口的请求签名机制
- **AppSign**：哔哩哔哩 App 端接口的请求签名机制

---

## 需求

### 需求 1：扫码登录

**用户故事：** 作为用户，我希望通过扫描二维码完成登录，以便安全地访问哔哩哔哩账号内容。

#### 验收标准

1. WHEN 用户进入登录页面，THE App SHALL 调用 TV 端授权码接口（`/x/passport-tv-login/qrcode/auth_code`）生成二维码，并在 3 秒内将二维码渲染到屏幕上。

2. WHEN 二维码渲染完成，THE QrCodePoller SHALL 每隔 3 秒轮询一次扫码状态接口（`/x/passport-tv-login/qrcode/poll`），直到登录成功或二维码过期。

3. WHEN 轮询接口返回 `code == 0`（登录成功），THE AuthService SHALL 将返回的 `access_key`、`refresh_token` 及 Cookie 持久化到本地存储，并将登录状态通知给全局 Provider。

4. WHEN 轮询接口返回 `code == 86038`（二维码已过期），THE App SHALL 停止轮询并在界面上展示"二维码已过期，请刷新"的提示，同时提供刷新按钮。

5. WHEN 用户点击刷新按钮，THE App SHALL 重新请求授权码并渲染新的二维码，同时重启轮询流程。

6. IF 网络请求失败，THEN THE App SHALL 停止轮询，展示错误提示信息，并提供重试入口。

7. WHEN 登录成功，THE App SHALL 跳转至首页，并在界面上展示当前登录用户的头像与昵称。

8. WHILE 用户处于已登录状态，THE AuthService SHALL 在每次冷启动时从本地存储读取凭证，无需重新登录。

9. WHEN 界面宽度 >= 800px，THE App SHALL 将二维码以居中弹窗形式展示；WHEN 界面宽度 < 800px，THE App SHALL 将二维码以全屏页面形式展示。

---

### 需求 2：视频信息获取

**用户故事：** 作为用户，我希望在播放视频前能看到视频的标题、封面、UP 主信息及分 P 列表，以便了解视频内容。

#### 验收标准

1. WHEN 用户通过 BVid 进入视频详情页，THE VideoService SHALL 调用视频详情接口（`/x/web-interface/view`）获取视频元数据，并在 3 秒内完成渲染。

2. THE App SHALL 在视频详情页展示以下信息：视频标题、封面图、UP 主昵称与头像、播放量、点赞数、视频简介。

3. WHEN 视频包含多个分 P（`pages` 列表长度大于 1），THE App SHALL 展示分 P 选择列表，并默认选中第一 P。

4. WHEN 用户选择某一分 P，THE VideoService SHALL 使用对应的 CID 重新获取播放地址。

5. IF 视频详情接口返回非 0 错误码，THEN THE App SHALL 展示对应的错误信息（如"视频不存在或已被删除"）。

---

### 需求 3：视频播放

**用户故事：** 作为用户，我希望能流畅播放哔哩哔哩视频，以便获得与官方客户端一致的观看体验。

#### 验收标准

1. WHEN 用户进入视频详情页，THE VideoService SHALL 调用播放地址接口（`/x/player/wbi/playurl`，携带 Wbi 签名）获取 DASH 格式的视频流地址，`fnval` 参数设置为 `4048`。

2. WHEN 播放地址获取成功，THE VideoPlayer SHALL 使用 media_kit 库加载视频流，并在 5 秒内开始播放。

3. THE VideoPlayer SHALL 默认选择当前网络条件下可用的最高画质（优先顺序：1080P60 > 1080P > 720P > 480P > 360P）。

4. WHILE 视频正在播放，THE VideoPlayer SHALL 提供以下控制功能：播放/暂停、进度拖拽、全屏切换、画质切换。

5. WHILE 视频正在播放，THE VideoPlayer SHALL 每隔 15 秒向心跳接口（`/x/click-interface/web/heartbeat`）上报播放进度。

6. IF 播放地址接口返回 `-404` 错误码，THEN THE App SHALL 展示"视频不存在或已被删除"的提示。

7. IF 播放地址接口返回 `87008` 错误码，THEN THE App SHALL 展示"该视频为专属视频，可能需要充电观看"的提示。

8. IF 网络中断导致播放失败，THEN THE VideoPlayer SHALL 展示加载失败提示，并提供重试按钮。

9. WHEN 界面宽度 >= 800px，THE VideoPlayer SHALL 以宽屏横向布局展示：左侧区域分为上下两部分，上方为 16:9 播放器，下方依次展示视频信息与评论区；右侧固定宽度区域展示相关推荐视频列表。WHEN 界面宽度 < 800px，THE VideoPlayer SHALL 以窄屏布局展示：播放器位于页面顶部（16:9），下方依次展示视频信息与评论区。

10. WHEN 用户在手机端点击全屏按钮，THE VideoPlayer SHALL 切换为横屏全屏模式，隐藏系统状态栏。

11. WHEN 用户在 PC 端点击全屏按钮，THE VideoPlayer SHALL 将播放器扩展至整个窗口。

---

### 需求 4：网络层基础设施

**用户故事：** 作为开发者，我希望有统一的网络请求基础设施，以便所有接口调用都能正确携带认证信息、处理错误并支持重试。

#### 验收标准

1. THE App SHALL 使用 dio 库作为 HTTP 客户端，基础 URL 配置为 `https://api.bilibili.com`，连接超时与响应超时均设置为 10 秒。

2. WHEN 发起需要登录的接口请求，THE App SHALL 自动在请求头或参数中携带 `access_key`（App 端接口）或 Cookie 中的 `SESSDATA`（Web 端接口）。

3. WHEN 接口请求失败（网络错误或 HTTP 5xx），THE App SHALL 自动重试最多 2 次，每次重试间隔 1 秒。

4. THE App SHALL 支持 Wbi 签名（用于 Web 端接口）与 AppSign 签名（用于 App 端接口）两种请求签名机制。

5. IF 接口返回 HTTP 401 或业务码表示登录态失效，THEN THE App SHALL 清除本地凭证，并引导用户重新登录。

---

### 需求 5：多端自适应布局

**用户故事：** 作为用户，我希望在手机和 PC 上都能获得适配当前设备的界面布局，以便在不同设备上都有良好的使用体验。

#### 验收标准

1. THE App SHALL 在启动时通过 `OS.isPCOS`、`OS.isMobileOS`、`OS.isHarmony` 获取平台信息注入全局 Provider，但布局决策以 `LayoutBuilder`/`MediaQuery` 获取的界面尺寸为主要依据。

2. WHERE 运行平台为鸿蒙（`OS.isHarmony == true`），THE App SHALL 在启动时调用 `OS.initHarmonyDeviceType()` 初始化设备类型，再进行 PC/Mobile 判断。

3. WHEN 界面宽度 >= 800px，THE App SHALL 使用宽屏布局：导航栏位于左侧，内容区域自适应剩余宽度。

4. WHEN 界面宽度 < 800px，THE App SHALL 使用底部导航栏布局，内容区域占满屏幕宽度。

5. THE App SHALL 使用 Material Design 3 设计规范，UI 风格对齐官方哔哩哔哩应用，主色调使用哔哩哔哩品牌粉色（`#FB7299`）。

6. WHEN `Platform.isWindows || Platform.isLinux || Platform.isMacOS` 为 true，THE App SHALL 启用 `window_manager` 相关功能（如窗口置顶、窗口大小控制）；THE App SHALL NOT 使用 `OS.isPCOS` 作为 `window_manager` 功能的启用条件。
