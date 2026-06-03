import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cover_config.dart';
import '../models/cover_preset.dart';
import '../presets.dart';
import '../renderer/cover_renderer.dart';

class CoverGeneratorController extends ChangeNotifier {
  // ─── Input state ───
  String title = 'My App';
  String subtitle = 'The best app ever';
  String footerText = '';
  CoverLayout layout = CoverLayoutPresets.classicGradient;

  Color startColor = const Color(0xFF667eea);
  Color endColor = const Color(0xFF764ba2);
  String? fontFamily;
  String? fontPackage;
  String? titleFontFamily;
  String? subtitleFontFamily;
  String? footerFontFamily;
  bool autoExtractBackgroundColor = true;

  int selectedPresetIndex = 0;
  double customWidth = 1290;
  double customHeight = 2796;

  ui.Image? screenshotImage;
  String screenshotPath = '';

  // ─── Output state ───
  Uint8List? generatedBytes;
  bool isGenerating = false;

  // ─── Preset shortcuts ───
  List<CoverPreset> get presets => kCoverPresets;

  CoverPreset? get currentPreset => selectedPresetIndex < presets.length
      ? presets[selectedPresetIndex]
      : null;

  bool get isCustomSize => selectedPresetIndex >= presets.length;

  double get effectiveWidth =>
      isCustomSize ? customWidth : currentPreset!.width;

  double get effectiveHeight =>
      isCustomSize ? customHeight : currentPreset!.height;

  // ─── Mutations (call notifyListeners after) ───

  void updateTitle(String v) {
    title = v;
    notifyListeners();
  }

  void updateSubtitle(String v) {
    subtitle = v;
    notifyListeners();
  }

  void updateFooterText(String v) {
    footerText = v;
    notifyListeners();
  }

  void updateLayout(CoverLayout v) {
    layout = v;
    notifyListeners();
  }

  void updateStartColor(Color v) {
    startColor = v;
    notifyListeners();
  }

  void updateEndColor(Color v) {
    endColor = v;
    notifyListeners();
  }

  void updateFontFamily(String? v) {
    fontFamily = v;
    notifyListeners();
  }

  void updateFontPackage(String? v) {
    fontPackage = v;
    notifyListeners();
  }

  void updateTitleFontFamily(String? v) {
    titleFontFamily = v;
    notifyListeners();
  }

  void updateSubtitleFontFamily(String? v) {
    subtitleFontFamily = v;
    notifyListeners();
  }

  void updateFooterFontFamily(String? v) {
    footerFontFamily = v;
    notifyListeners();
  }

  void updateAutoExtractBackgroundColor(bool v) {
    autoExtractBackgroundColor = v;
    notifyListeners();
  }

  void selectPreset(int index) {
    selectedPresetIndex = index;
    notifyListeners();
  }

  void updateCustomWidth(double v) {
    customWidth = v;
    notifyListeners();
  }

  void updateCustomHeight(double v) {
    customHeight = v;
    notifyListeners();
  }

  void setScreenshot(ui.Image image, {String path = ''}) {
    screenshotImage?.dispose();
    screenshotImage = image;
    screenshotPath = path;
    if (autoExtractBackgroundColor) {
      _extractAndApplyBackgroundColors(image);
    }
    notifyListeners();
  }

  Future<void> _extractAndApplyBackgroundColors(ui.Image image) async {
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return;

      final bytes = data.buffer.asUint8List();
      final w = image.width;
      final h = image.height;
      if (w <= 0 || h <= 0) return;

      // Sample top region so background color matches screenshot header area.
      final sampleTop = 0;
      final sampleBottom = (h * 0.28).toInt().clamp(1, h);
      final sampleLeft = (w * 0.08).toInt().clamp(0, w - 1);
      final sampleRight = (w * 0.92).toInt().clamp(1, w);

      final stepX = (w / 48).toInt().clamp(1, 24);
      final stepY = (h / 96).toInt().clamp(1, 24);

      var r = 0.0;
      var g = 0.0;
      var b = 0.0;
      var count = 0;

      for (var y = sampleTop; y < sampleBottom; y += stepY) {
        for (var x = sampleLeft; x < sampleRight; x += stepX) {
          final i = (y * w + x) * 4;
          final rr = bytes[i];
          final gg = bytes[i + 1];
          final bb = bytes[i + 2];
          final aa = bytes[i + 3];
          if (aa < 20) continue;
          r += rr;
          g += gg;
          b += bb;
          count++;
        }
      }

      if (count == 0) return;
      final base = Color.fromARGB(
        255,
        (r / count).round().clamp(0, 255),
        (g / count).round().clamp(0, 255),
        (b / count).round().clamp(0, 255),
      );

      final hsl = HSLColor.fromColor(base);
      final s = (hsl.saturation * 0.82).clamp(0.18, 0.75);
      final l = hsl.lightness;
      final start = hsl
          .withSaturation(s)
          .withLightness((l + 0.12).clamp(0.0, 1.0))
          .toColor();
      final end = hsl
          .withHue((hsl.hue + 18) % 360)
          .withSaturation((s + 0.08).clamp(0.0, 1.0))
          .withLightness((l - 0.08).clamp(0.0, 1.0))
          .toColor();

      startColor = start;
      endColor = end;
      notifyListeners();
    } catch (e) {
      debugPrint('[cover_generator] Failed to extract colors from screenshot: $e');
    }
  }

  // ─── Actions ───

  Future<void> pickScreenshot() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2160,
      maxHeight: 4680,
      imageQuality: 95,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setScreenshot(frame.image, path: file.path);
  }

  Future<String?> generate() async {
    if (title.isEmpty) return '请输入标题';

    isGenerating = true;
    notifyListeners();
    try {
      final config = buildConfig();
      generatedBytes = await CoverRenderer.render(config);
      notifyListeners();
      return null; // success
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> shareImage() async {
    final bytes = generatedBytes;
    if (bytes == null) return;

    final tempDir = await Directory.systemTemp.createTemp('cover_gen_');
    final file = File(
      '${tempDir.path}/cover_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'image/png'),
    ], text: title);
  }

  Future<bool> saveImage() async {
    final bytes = generatedBytes;
    if (bytes == null) return false;

    final name = 'cover_${DateTime.now().millisecondsSinceEpoch}';
    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: name,
    );
    final ok = result['isSuccess'] == true || result['success'] == true;
    return ok;
  }

  CoverConfig buildConfig() {
    return CoverConfig(
      title: title,
      subtitle: subtitle,
      width: effectiveWidth,
      height: effectiveHeight,
      startColor: startColor,
      endColor: endColor,
      fontFamily: fontFamily,
      fontPackage: fontPackage,
      titleFontFamily: titleFontFamily,
      subtitleFontFamily: subtitleFontFamily,
      footerFontFamily: footerFontFamily,
      screenshot: screenshotImage,
      footerText: footerText.isEmpty ? null : footerText,
      layout: layout,
    );
  }

  @override
  void dispose() {
    screenshotImage?.dispose();
    super.dispose();
  }
}
