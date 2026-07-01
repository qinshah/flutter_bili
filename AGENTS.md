# flutter_bili — Bilibili client built with Flutter

## Project
- A cross-platform Bilibili (哔哩哔哩) app targeting Android, iOS, macOS, Windows, Linux, and OpenHarmony.
- Stack: Flutter 3.x (SDK ^3.9.2), Dart, Provider for state management, go_router for navigation, Dio for HTTP, Hive CE for local storage, media-kit + fvp for video playback.
- Entry point: `lib/main.dart` → `BiliApp` → `MaterialApp.router` with `routerConfig: router`.

## Commands
- **Get dependencies:** `flutter pub get`
- **Run (debug):** `flutter run` (pick a connected device/platform)
- **Build APK (Android):** `flutter build apk`
- **Build iOS:** `flutter build ios`
- **Build macOS:** `flutter build macos`
- **Build Windows:** `flutter build windows`
- **Build Linux:** `flutter build linux`
- **Code generation** (Hive adapters): `dart run build_runner build --delete-conflicting-outputs`
- **Lint:** `dart analyze` (uses `package:flutter_lints/flutter.yaml`)
- **Tests:** `flutter test` (note: `test/` directory exists but is currently empty)

## Architecture
```
lib/
├── main.dart              # App entry, Provider setup, MaterialApp.router
├── core/http/             # Dio HTTP client (Request singleton), B站 API endpoints, interceptors
├── service/               # App-level ChangeNotifier singletons — AuthS, MediaS, SettingsS, StorageS
├── route/                 # GoRouter config (router.dart), route observer (RO), route constants (Routes)
├── module/                # Feature modules, each containing views (*_v.dart), view-models (*_vm.dart), and local models/
│   ├── home/              # Home scaffold (bottom nav: 推荐/动态/我的), recommend feed
│   ├── video/             # Video detail + player (full-screen, PiP, float)
│   ├── dynamic/           # Followed-UP dynamic feed
│   ├── login/             # QR-code TV login
│   ├── mine/              # User profile / history / favorites
│   ├── search/            # Search
│   ├── setting/           # Settings (player kernel, danmaku, quality, data)
│   ├── up/                # UP主 space + archives
│   ├── message/           # Messages
│   └── 404/               # Not-found placeholder
├── infrastructure/        # Platform abstractions — media_player (MediaPlayer interface, fvp / media-kit impls)
└── src/bindings/          # (dormant) Rust FFI serde/bincode bindings for rinf
```

## Conventions
- **Suffix naming:**
  - `*Vm` — ChangeNotifier ViewModel (e.g. `VideoPageVm`, `RecommendVm`)
  - `*V` — Widget / View (e.g. `VideoPageV`, `DynamicPageV`)
  - `*S` — Service singleton, accessed via static `.i` getter (e.g. `AuthS.i`, `MediaS.i`)
  - `*M` — Data model (e.g. `UserM`, `VideoQualityM`)
  - `*_http.dart` — Per-domain HTTP helper files under `core/http/`
- **State management:** Provider + ChangeNotifier. Services and ViewModels are exposed via `ChangeNotifierProvider` in the widget tree; views call `context.watch<T>()` / `context.read<T>()`.
- **Routing:** go_router declarative routes in `lib/route/router.dart`. Route paths are constants on the `Routes` abstract class. Pages receive params via `state.extra`.
- **HTTP:** Single `Request()` singleton wrapping Dio. API URL constants in `lib/core/http/api.dart`. Auth/cookie interceptor stack in `Request.init()`.
- **Code generation:** Hive TypeAdapters are generated with `build_runner` (`hive_ce_generator`). Run `dart run build_runner build` after editing `@HiveType` models.
- **Lint:** `flutter_lints` (5.x). Do not relax the analysis options without reason.
- **Do NOT** commit secrets or real cookies — `SESSDATA=xxx` in `request.dart` is a placeholder.

## Notes
- The `test/` directory exists but is empty; new tests go there (matching `lib/` structure).
- Rust FFI via `rinf` is commented out and currently dormant.
- Dependencies on local paths (`../../FP/u_widget`) mean the project expects sibling repos; contributors should adjust these or use the git fallbacks.

## Progress Tracking
项目使用两个文件跟踪进度，AI 每次会话**必须**读写它们：

| 文件 | 用途 |
|------|------|
| `tasks.md` | 任务列表，按优先级分"进行中 / 待办 / 已完成"，使用 `[x]` / `[ ]` 标记 |
| `CHANGELOG.md` | 变更日志，按 Added / Changed / Fixed 分类记录每次代码变更 |

**规则：**
- 会话开始时读取 `tasks.md` 了解当前任务状态。
- 每完成一个任务，立即更新 `tasks.md`（勾选并移到已完成）和 `CHANGELOG.md`（记录变更摘要）。
- 新增任务时追加到 `tasks.md` 对应区域。
- 不要只在脑中跟踪 — 必须落盘到这两个文件。
