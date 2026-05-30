import 'package:flutter/material.dart';

import '../controller/cover_generator_controller.dart';
import 'generated_result_page.dart';
import 'widgets/color_picker.dart';
import 'widgets/cover_preview.dart';
import 'widgets/size_selector.dart';
import 'widgets/text_inputs.dart';

/// Main cover generator page. Accepts an externally-provided [controller].
class CoverGeneratorPage extends StatefulWidget {
  final CoverGeneratorController controller;

  const CoverGeneratorPage({super.key, required this.controller});

  @override
  State<CoverGeneratorPage> createState() => _CoverGeneratorPageState();
}

class _CoverGeneratorPageState extends State<CoverGeneratorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _footerCtrl;

  CoverGeneratorController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: c.title)
      ..addListener(() => c.title = _titleCtrl.text);
    _subtitleCtrl = TextEditingController(text: c.subtitle)
      ..addListener(() => c.subtitle = _subtitleCtrl.text);
    _footerCtrl = TextEditingController(text: c.footerText)
      ..addListener(() => c.footerText = _footerCtrl.text);
    c.addListener(_onControllerUpdate);
    // Auto-generate preview on page load
    WidgetsBinding.instance.addPostFrameCallback((_) => c.generate());
  }

  @override
  void dispose() {
    c.removeListener(_onControllerUpdate);
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('封面生成器'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: CoverPreview(
                imageBytes: c.generatedBytes,
                aspectRatio: c.effectiveWidth / c.effectiveHeight,
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),

          // Controls
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverTextInputs(
                    titleController: _titleCtrl,
                    subtitleController: _subtitleCtrl,
                    footerController: _footerCtrl,
                  ),
                  const SizedBox(height: 20),
                  SizeSelector(
                    presets: c.presets,
                    selectedIndex: c.selectedPresetIndex,
                    onSelect: c.selectPreset,
                    customWidth: c.customWidth,
                    customHeight: c.customHeight,
                    onCustomWidthChanged: c.updateCustomWidth,
                    onCustomHeightChanged: c.updateCustomHeight,
                  ),
                  const SizedBox(height: 20),
                  GradientColorPicker(
                    startColor: c.startColor,
                    endColor: c.endColor,
                    onSelect: (i) {
                      c.updateStartColor(kGradientPresets[i][0]);
                      c.updateEndColor(kGradientPresets[i][1]);
                    },
                    onStartColorChanged: c.updateStartColor,
                    onEndColorChanged: c.updateEndColor,
                  ),
                  const SizedBox(height: 20),
                  _buildScreenshotSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom action bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: c.isGenerating ? null : _onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: c.isGenerating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '生成封面图',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGenerate() async {
    final error = await c.generate();
    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GeneratedResultPage(controller: c)),
    );
  }

  Widget _buildScreenshotSection() {
    final hasImage = c.screenshotImage != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '截图',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '已截取',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF43A047),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (hasImage) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 120,
              child: RawImage(image: c.screenshotImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: c.pickScreenshot,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasImage ? Icons.refresh : Icons.photo_library_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasImage ? '重新选择' : '从相册选择',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
