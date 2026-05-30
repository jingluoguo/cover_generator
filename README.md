# cover_generator

一个 Flutter 包，用于生成应用商店封面图（App Store、Play Store 等）。

支持自定义标题、副标题、渐变色、截图嵌入，采用 Canvas 渲染引擎，输出高质量 PNG 图片。

## ✨ 功能特性

- 🎨 **Canvas 渲染引擎** — 纯 `dart:ui` 绘制，确定性输出，无 widget 树依赖
- 📸 **截图捕获** — `CoverCaptureWrapper` 包裹任意 widget，一键截图
- 📐 **多尺寸预设** — iPhone 6.7"/6.5"/5.5"、iPad、Play Store、Android + 自定义尺寸
- 🌈 **渐变色选择** — 10 种预设渐变 + HSV 调色盘自定义
- ✏️ **文本自定义** — 标题、副标题、底部文字
- 📤 **分享 & 保存** — 基于 `share_plus` 的分享功能
- 🧩 **零侵入** — 不依赖宿主项目路由，独立运行

## 📦 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  cover_generator: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 🚀 使用方式

### 方式一：包裹 Widget（推荐）

用 `CoverCaptureWrapper` 包裹任意 widget，点击浮动按钮即可截图并跳转到封面配置页：

```dart
import 'package:cover_generator/cover_generator.dart';

CoverCaptureWrapper(
  showButton: true,             // 控制按钮显隐
  backgroundColor: Colors.white, // 截图背景色
  appendStatusBar: true,         // 追加状态栏到截图顶部
  statusBarStyle: StatusBarStyle.ios,
  statusBarColor: Colors.black,
  statusBarTextColor: Colors.white,
  initialLayout: CoverLayoutPresets.editorialLightPhone, // 初始风格
  enableLayoutSelector: true, // 配置页是否允许切换风格
  // layoutOptions: CoverLayoutPresets.options, // 可传入自定义风格列表
  child: YourContentWidget(),
)
```

### 方式二：独立页面

直接打开封面生成器页面，从相册选择截图：

```dart
import 'package:cover_generator/cover_generator.dart';

final controller = CoverGeneratorController();
// 默认：选择/截取截图后自动提取顶部主色，更新背景渐变
// controller.updateAutoExtractBackgroundColor(false); // 如需关闭可手动设置
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => CoverGeneratorPage(controller: controller),
  ),
);

// 可选：默认使用“轻杂志风”模板
controller.updateLayout(CoverLayoutPresets.editorialLightPhone);
```

### 方式三：仅用渲染引擎

直接调用 Canvas 渲染器生成图片：

```dart
import 'package:cover_generator/cover_generator.dart';

final config = CoverConfig(
  title: 'My App',
  subtitle: 'The best app ever',
  width: 1290,
  height: 2796,
  startColor: Color(0xFF667eea),
  endColor: Color(0xFF764ba2),
  screenshot: myImage,  // 可选，dart:ui.Image
  layout: CoverLayoutPresets.editorialLightPhone, // 可选：版式模板
);

final pngBytes = await CoverRenderer.render(config);
```

## 📐 内置尺寸预设

| 预设        | 尺寸        | 用途                          |
| ----------- | ----------- | ----------------------------- |
| iPhone 6.7" | 1290 × 2796 | App Store · iPhone 15 Pro Max |
| iPhone 6.5" | 1284 × 2778 | App Store · iPhone 11 Pro Max |
| iPhone 5.5" | 1242 × 2208 | App Store · iPhone 8 Plus     |
| iPad 12.9"  | 2048 × 2732 | App Store · iPad Pro          |
| Play Store  | 1024 × 500  | Play Store · Feature Graphic  |
| Android     | 1080 × 1920 | Play Store · Screenshot       |
| 自定义      | 任意        | 用户输入                      |

## 🏗️ 架构

```
lib/
├── cover_generator.dart              # Barrel export
└── src/
    ├── models/
    │   ├── cover_config.dart         # 封面配置模型
    │   └── cover_preset.dart         # 尺寸预设模型
    ├── presets.dart                  # 预设尺寸列表
    ├── renderer/
    │   └── cover_renderer.dart       # Canvas 渲染引擎
    ├── controller/
    │   └── cover_generator_controller.dart  # ChangeNotifier 状态管理
    └── ui/
        ├── cover_capture_wrapper.dart     # 截图包裹 widget
        ├── cover_generator_page.dart      # 配置页
        ├── generated_result_page.dart     # 结果预览页
        └── widgets/
            ├── cover_preview.dart
            ├── size_selector.dart
            ├── text_inputs.dart
            ├── color_picker.dart
            └── hsv_color_picker.dart
```

## ⚙️ 平台配置

### iOS

在 `ios/Runner/Info.plist` 中添加相册权限描述：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择截图</string>
```

### Android

无需额外配置。`share_plus` v7+ 和 `image_picker` 已自动处理权限和文件共享。

## 📝 依赖

| 包             | 用途           |
| -------------- | -------------- |
| `flutter`      | UI 框架        |
| `image_picker` | 从相册选择截图 |
| `share_plus`   | 分享生成的图片 |

## 📄 License

MIT License. 详见 [LICENSE](LICENSE)。
