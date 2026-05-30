import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cover_config.dart';
import '../models/cover_preset.dart';
import '../presets.dart';
import '../renderer/cover_renderer.dart';

class CoverGeneratorController extends ChangeNotifier {
  // ─── Input state ───
  String title = '';
  String subtitle = '';
  String footerText = '';

  Color startColor = const Color(0xFF667eea);
  Color endColor = const Color(0xFF764ba2);

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

  CoverPreset? get currentPreset =>
      selectedPresetIndex < presets.length
          ? presets[selectedPresetIndex]
          : null;

  bool get isCustomSize => selectedPresetIndex >= presets.length;

  double get effectiveWidth =>
      isCustomSize ? customWidth : currentPreset!.width;

  double get effectiveHeight =>
      isCustomSize ? customHeight : currentPreset!.height;

  // ─── Mutations (call notifyListeners after) ───

  void updateTitle(String v) { title = v; notifyListeners(); }
  void updateSubtitle(String v) { subtitle = v; notifyListeners(); }
  void updateFooterText(String v) { footerText = v; notifyListeners(); }

  void updateStartColor(Color v) { startColor = v; notifyListeners(); }
  void updateEndColor(Color v) { endColor = v; notifyListeners(); }

  void selectPreset(int index) { selectedPresetIndex = index; notifyListeners(); }
  void updateCustomWidth(double v) { customWidth = v; notifyListeners(); }
  void updateCustomHeight(double v) { customHeight = v; notifyListeners(); }

  void setScreenshot(ui.Image image, {String path = ''}) {
    screenshotImage?.dispose();
    screenshotImage = image;
    screenshotPath = path;
    notifyListeners();
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
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: title,
    );
  }

  CoverConfig buildConfig() {
    return CoverConfig(
      title: title,
      subtitle: subtitle,
      width: effectiveWidth,
      height: effectiveHeight,
      startColor: startColor,
      endColor: endColor,
      screenshot: screenshotImage,
      footerText: footerText.isEmpty ? null : footerText,
    );
  }

  @override
  void dispose() {
    screenshotImage?.dispose();
    super.dispose();
  }
}
