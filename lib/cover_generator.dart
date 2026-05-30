/// Cover Generator Package
///
/// A self-contained package for generating promotional cover images
/// (App Store, Play Store, etc.) with customizable title, subtitle,
/// gradient colors, and embedded screenshots.
///
/// Usage:
/// ```dart
/// import 'package:cover_generator/cover_generator.dart';
///
/// // Wrap any widget with the capture button
/// CoverCaptureWrapper(
///   showButton: true,
///   child: MyContent(),
/// )
/// ```
library cover_generator;

export 'src/controller/cover_generator_controller.dart';
export 'src/models/cover_config.dart';
export 'src/models/cover_preset.dart';
export 'src/presets.dart';
export 'src/renderer/cover_renderer.dart';
export 'src/ui/cover_capture_wrapper.dart';
export 'src/ui/cover_generator_page.dart';
export 'src/ui/generated_result_page.dart';
export 'src/ui/widgets/color_picker.dart' show kGradientPresets;
