## 1.0.1 - 2026-06-01

### Added
- 新增布局参数保存功能，并支持已保存配置快速应用
- 新增一键保存到系统相册能力，并补齐权限说明
- 新增封面文本字体传参与 package 字体解析支持
- 新增布局参数恢复默认能力

### Changed
- 调整默认尺寸配置
- 布局参数滑动时机优化为滑动结束后重绘

### Fixed
- 修复保存配置时可能发生的崩溃问题

## 1.0.0

- Initial release
- Canvas-based cover image rendering engine
- `CoverCaptureWrapper` widget for capturing any widget as a screenshot
- Built-in size presets: iPhone 6.7"/6.5"/5.5", iPad, Play Store, Android
- Custom size input support
- 10 gradient color presets
- HSV color picker for custom gradients
- Title, subtitle, and footer text input
- Screenshot from gallery
- Share and save generated images
- Zero external state management dependencies (pure ChangeNotifier)
- Self-contained routing (no host app route injection required)
