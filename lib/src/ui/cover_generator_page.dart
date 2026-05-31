import 'package:flutter/material.dart';

import '../controller/cover_generator_controller.dart';
import '../models/cover_config.dart';
import 'generated_result_page.dart';
import 'widgets/color_picker.dart';
import 'widgets/cover_preview.dart';
import 'widgets/size_selector.dart';
import 'widgets/text_inputs.dart';

/// Main cover generator page. Accepts an externally-provided [controller].
class CoverGeneratorPage extends StatefulWidget {
  final CoverGeneratorController controller;
  final bool enableLayoutSelector;
  final List<CoverLayoutOption> layoutOptions;

  const CoverGeneratorPage({
    super.key,
    required this.controller,
    this.enableLayoutSelector = true,
    this.layoutOptions = CoverLayoutPresets.options,
  });

  @override
  State<CoverGeneratorPage> createState() => _CoverGeneratorPageState();
}

class _CoverGeneratorPageState extends State<CoverGeneratorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _footerCtrl;
  final Map<String, double> _pendingSliderValues = {};

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

  void _updateLayout(CoverLayout layout) {
    c.updateLayout(layout);
    c.generate();
  }

  void _resetLayoutToDefault() {
    final defaultLayout = widget.layoutOptions.isNotEmpty
        ? widget.layoutOptions.first.layout
        : CoverLayoutPresets.classicGradient;
    setState(() => _pendingSliderValues.clear());
    _updateLayout(defaultLayout);
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
                  if (widget.enableLayoutSelector) ...[
                    _buildLayoutSection(),
                    const SizedBox(height: 20),
                  ],
                  _buildLayoutEditorSection(),
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

  Widget _buildLayoutSection() {
    final options = widget.layoutOptions;
    final selectedIndex = options.indexWhere((o) => o.layout == c.layout);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '风格',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < options.length; i++)
              GestureDetector(
                onTap: () => _updateLayout(options[i].layout),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? const Color(0xFF667eea)
                        : Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    options[i].label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: i == selectedIndex ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLayoutEditorSection() {
    final layout = c.layout;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      title: const Text(
        '布局参数',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: const Text(
        '直接调 CoverLayout（滑动结束后预览更新）',
        style: TextStyle(fontSize: 12, color: Colors.black45),
      ),
      trailing: TextButton(
        onPressed: _resetLayoutToDefault,
        child: const Text('恢复默认'),
      ),
      children: [
        _buildEnumDropdown<CoverBackgroundStyle>(
          label: '背景样式',
          value: layout.backgroundStyle,
          values: CoverBackgroundStyle.values,
          labelBuilder: (v) => switch (v) {
            CoverBackgroundStyle.gradient => '渐变背景',
            CoverBackgroundStyle.softLight => '浅色柔光',
          },
          onChanged: (v) => _updateLayout(layout.copyWith(backgroundStyle: v)),
        ),
        _buildEnumDropdown<ScreenshotFitMode>(
          label: '截图适配',
          value: layout.screenshotFitMode,
          values: ScreenshotFitMode.values,
          labelBuilder: (v) => switch (v) {
            ScreenshotFitMode.coverTopCenter => '宽铺满 顶部优先',
            ScreenshotFitMode.containTopCenter => '完整显示 顶部优先',
            ScreenshotFitMode.containCenter => '完整显示 居中',
          },
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotFitMode: v)),
        ),
        _buildEnumDropdown<CoverStatusBarStyle>(
          label: '状态栏样式',
          value: layout.statusBarStyle,
          values: CoverStatusBarStyle.values,
          labelBuilder: (v) => switch (v) {
            CoverStatusBarStyle.ios => 'iOS',
            CoverStatusBarStyle.android => 'Android',
          },
          onChanged: (v) => _updateLayout(layout.copyWith(statusBarStyle: v)),
        ),
        _buildSwitchRow(
          label: '背景光斑',
          value: layout.showAmbientShapes,
          onChanged: (v) => _updateLayout(layout.copyWith(showAmbientShapes: v)),
        ),
        _buildSwitchRow(
          label: '仅顶部圆角',
          value: layout.screenshotTopOnlyRounded,
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotTopOnlyRounded: v)),
        ),
        _buildSwitchRow(
          label: '启用手机壳',
          value: layout.deviceFrameEnabled,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceFrameEnabled: v)),
        ),
        _buildSwitchRow(
          label: '灵动岛 / 刘海',
          value: layout.deviceIslandEnabled,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceIslandEnabled: v)),
        ),
        _buildSwitchRow(
          label: '状态栏',
          value: layout.statusBarEnabled,
          onChanged: (v) => _updateLayout(layout.copyWith(statusBarEnabled: v)),
        ),
        _buildSwitchRow(
          label: 'Home Indicator',
          value: layout.homeIndicatorEnabled,
          onChanged: (v) => _updateLayout(layout.copyWith(homeIndicatorEnabled: v)),
        ),
        _buildSliderRow(
          label: '顶部留白',
          value: layout.topMarginRatio,
          min: 0.0,
          max: 0.2,
          onChanged: (v) => _updateLayout(layout.copyWith(topMarginRatio: v)),
        ),
        _buildSliderRow(
          label: '左右外边距',
          value: layout.sideMarginRatio,
          min: 0.0,
          max: 0.16,
          onChanged: (v) => _updateLayout(layout.copyWith(sideMarginRatio: v)),
        ),
        _buildSliderRow(
          label: '标题副标题间距',
          value: layout.titleSubtitleSpacingRatio,
          min: 0.0,
          max: 0.04,
          onChanged: (v) => _updateLayout(layout.copyWith(titleSubtitleSpacingRatio: v)),
        ),
        _buildSliderRow(
          label: '区块间距',
          value: layout.sectionGapRatio,
          min: 0.0,
          max: 0.06,
          onChanged: (v) => _updateLayout(layout.copyWith(sectionGapRatio: v)),
        ),
        _buildSliderRow(
          label: '截图圆角',
          value: layout.screenshotCornerRadiusRatio,
          min: 0.0,
          max: 0.2,
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotCornerRadiusRatio: v)),
        ),
        _buildSliderRow(
          label: '阴影偏移',
          value: layout.screenshotShadowDyRatio,
          min: 0.0,
          max: 0.04,
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotShadowDyRatio: v)),
        ),
        _buildSliderRow(
          label: '阴影模糊',
          value: layout.screenshotShadowBlurRatio,
          min: 0.0,
          max: 0.08,
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotShadowBlurRatio: v)),
        ),
        _buildSliderRow(
          label: '截图描边',
          value: layout.screenshotBorderWidthRatio,
          min: 0.0,
          max: 0.02,
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotBorderWidthRatio: v)),
        ),
        _buildSliderRow(
          label: '截图最小高度',
          value: layout.screenshotHeightMinRatio,
          min: 0.2,
          max: 0.8,
          onChanged: (v) => _updateLayout(layout.copyWith(screenshotHeightMinRatio: v)),
        ),
        _buildSliderRow(
          label: '状态栏高度',
          value: layout.statusBarHeightRatio,
          min: 0.03,
          max: 0.12,
          onChanged: (v) => _updateLayout(layout.copyWith(statusBarHeightRatio: v)),
        ),
        _buildSliderRow(
          label: '边框厚度',
          value: layout.deviceFrameThicknessRatio,
          min: 0.0,
          max: 0.08,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceFrameThicknessRatio: v)),
        ),
        _buildSliderRow(
          label: '屏幕左右内缩',
          value: layout.deviceScreenInsetXRatio,
          min: 0.0,
          max: 3.0,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceScreenInsetXRatio: v)),
        ),
        _buildSliderRow(
          label: '屏幕上下内缩',
          value: layout.deviceScreenInsetYRatio,
          min: 0.0,
          max: 4.0,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceScreenInsetYRatio: v)),
        ),
        _buildSliderRow(
          label: '灵动岛宽度',
          value: layout.deviceIslandWidthRatio,
          min: 0.1,
          max: 0.6,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceIslandWidthRatio: v)),
        ),
        _buildSliderRow(
          label: '灵动岛高度',
          value: layout.deviceIslandHeightRatio,
          min: 0.02,
          max: 0.14,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceIslandHeightRatio: v)),
        ),
        _buildSliderRow(
          label: '灵动岛顶部偏移',
          value: layout.deviceIslandTopInsetRatio,
          min: 0.0,
          max: 0.08,
          onChanged: (v) => _updateLayout(layout.copyWith(deviceIslandTopInsetRatio: v)),
        ),
        _buildSliderRow(
          label: 'Home Indicator 宽度',
          value: layout.homeIndicatorWidthRatio,
          min: 0.1,
          max: 0.5,
          onChanged: (v) => _updateLayout(layout.copyWith(homeIndicatorWidthRatio: v)),
        ),
        _buildSliderRow(
          label: 'Home Indicator 高度',
          value: layout.homeIndicatorHeightRatio,
          min: 0.004,
          max: 0.04,
          onChanged: (v) => _updateLayout(layout.copyWith(homeIndicatorHeightRatio: v)),
        ),
        _buildSliderRow(
          label: 'Home Indicator 底部偏移',
          value: layout.homeIndicatorBottomInsetRatio,
          min: 0.0,
          max: 0.08,
          onChanged: (v) => _updateLayout(layout.copyWith(homeIndicatorBottomInsetRatio: v)),
        ),
        _buildFrameColorSection(layout),
      ],
    );
  }

  Widget _buildFrameColorSection(CoverLayout layout) {
    const colors = [
      Color(0xFF06070A),
      Color(0xFF101114),
      Color(0xFF1D1F24),
      Color(0xFFE9EDF2),
      Color(0xFFBFC7D1),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '边框颜色',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in colors)
                GestureDetector(
                  onTap: () => _updateLayout(layout.copyWith(deviceFrameColor: color)),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: layout.deviceFrameColor == color
                            ? const Color(0xFF667eea)
                            : Colors.black12,
                        width: layout.deviceFrameColor == color ? 2 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    final sliderValue = (_pendingSliderValues[label] ?? value).clamp(min, max);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              Text(
                sliderValue.toStringAsFixed(3),
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          Slider(
            value: sliderValue,
            min: min,
            max: max,
            onChanged: (next) {
              setState(() => _pendingSliderValues[label] = next);
            },
            onChangeEnd: (next) {
              setState(() => _pendingSliderValues.remove(label));
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnumDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            initialValue: value,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
            ),
            items: [
              for (final item in values)
                DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
            ],
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
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
