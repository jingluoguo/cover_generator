import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Configuration for generating a promotional cover image.
class CoverConfig {
  final String title;
  final String subtitle;
  final double width;
  final double height;
  final Color startColor;
  final Color endColor;
  final ui.Image? screenshot;
  final String? footerText;
  final CoverLayout layout;

  const CoverConfig({
    required this.title,
    required this.subtitle,
    required this.width,
    required this.height,
    required this.startColor,
    required this.endColor,
    this.screenshot,
    this.footerText,
    this.layout = const CoverLayout(),
  });

  CoverConfig copyWith({
    String? title,
    String? subtitle,
    double? width,
    double? height,
    Color? startColor,
    Color? endColor,
    ui.Image? screenshot,
    String? footerText,
    CoverLayout? layout,
  }) {
    return CoverConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      width: width ?? this.width,
      height: height ?? this.height,
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
      screenshot: screenshot ?? this.screenshot,
      footerText: footerText ?? this.footerText,
      layout: layout ?? this.layout,
    );
  }
}

enum CoverBackgroundStyle { gradient, softLight }

enum ScreenshotFitMode { coverTopCenter, containTopCenter, containCenter }

class CoverLayout {
  /// 背景样式：`gradient` 为渐变背景，`softLight` 为浅色柔光背景。
  final CoverBackgroundStyle backgroundStyle;

  /// 是否绘制背景装饰光斑。
  /// true 更有氛围感，false 更干净极简。
  final bool showAmbientShapes;

  /// 顶部留白比例（相对整张图高度）。
  /// 值越大，标题区整体越往下。
  final double topMarginRatio;

  /// 左右外边距比例（相对整张图宽度）。
  /// 值越大，手机壳离画布左右边更远。
  final double sideMarginRatio;

  /// 标题与副标题之间的垂直间距比例（相对整张图高度）。
  final double titleSubtitleSpacingRatio;

  /// 各主要区块（标题区/截图区/底部文案）之间的间距比例。
  final double sectionGapRatio;

  /// 截图内容圆角比例（相对截图区域宽度）。
  /// 值越大，圆角越明显。
  final double screenshotCornerRadiusRatio;

  /// 截图阴影的垂直偏移比例（相对截图区域高度）。
  final double screenshotShadowDyRatio;

  /// 截图阴影模糊半径比例（相对截图区域宽度）。
  final double screenshotShadowBlurRatio;

  /// 截图描边粗细比例（相对截图区域宽度）。
  /// 为 0 可关闭描边视觉。
  final double screenshotBorderWidthRatio;

  /// 截图区域最小高度比例（相对整张图高度）。
  /// 防止标题过长时截图区域被挤得过小。
  final double screenshotHeightMinRatio;

  /// 截图适配模式：
  /// - `coverTopCenter`: 按宽度铺满并顶部居中（优先显示顶部）
  /// - `containTopCenter`: 完整显示并顶部居中
  /// - `containCenter`: 完整显示并居中
  final ScreenshotFitMode screenshotFitMode;

  /// 是否仅保留顶部圆角。
  /// true 适合“上圆下直”海报风格，false 为四角统一圆角。
  final bool screenshotTopOnlyRounded;

  /// 是否启用外层设备黑色边框（手机壳效果）。
  final bool deviceFrameEnabled;

  /// 设备边框颜色。
  final Color deviceFrameColor;

  /// 设备边框厚度比例（相对截图区域宽度）。
  /// 值越大，黑边越厚。
  final double deviceFrameThicknessRatio;

  /// 屏幕内容相对边框的横向内缩系数（基于边框厚度）。
  /// 值越大，截图离左右黑边越远。
  final double deviceScreenInsetXRatio;

  /// 屏幕内容相对边框的纵向内缩系数（基于边框厚度）。
  /// 值越大，截图离上下黑边越远。
  final double deviceScreenInsetYRatio;

  const CoverLayout({
    this.backgroundStyle = CoverBackgroundStyle.gradient,
    this.showAmbientShapes = true,
    this.topMarginRatio = 0.04,
    this.sideMarginRatio = 0.07,
    this.titleSubtitleSpacingRatio = 0.01,
    this.sectionGapRatio = 0.02,
    this.screenshotCornerRadiusRatio = 0.035,
    this.screenshotShadowDyRatio = 0.006,
    this.screenshotShadowBlurRatio = 0.016,
    this.screenshotBorderWidthRatio = 0.0015,
    this.screenshotHeightMinRatio = 0.42,
    this.screenshotFitMode = ScreenshotFitMode.coverTopCenter,
    this.screenshotTopOnlyRounded = true,
    this.deviceFrameEnabled = false,
    this.deviceFrameColor = const Color(0xFF0B0C0F),
    this.deviceFrameThicknessRatio = 0.026,
    this.deviceScreenInsetXRatio = 1.0,
    this.deviceScreenInsetYRatio = 1.0,
  });

  CoverLayout copyWith({
    CoverBackgroundStyle? backgroundStyle,
    bool? showAmbientShapes,
    double? topMarginRatio,
    double? sideMarginRatio,
    double? titleSubtitleSpacingRatio,
    double? sectionGapRatio,
    double? screenshotCornerRadiusRatio,
    double? screenshotShadowDyRatio,
    double? screenshotShadowBlurRatio,
    double? screenshotBorderWidthRatio,
    double? screenshotHeightMinRatio,
    ScreenshotFitMode? screenshotFitMode,
    bool? screenshotTopOnlyRounded,
    bool? deviceFrameEnabled,
    Color? deviceFrameColor,
    double? deviceFrameThicknessRatio,
    double? deviceScreenInsetXRatio,
    double? deviceScreenInsetYRatio,
  }) {
    return CoverLayout(
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      showAmbientShapes: showAmbientShapes ?? this.showAmbientShapes,
      topMarginRatio: topMarginRatio ?? this.topMarginRatio,
      sideMarginRatio: sideMarginRatio ?? this.sideMarginRatio,
      titleSubtitleSpacingRatio:
          titleSubtitleSpacingRatio ?? this.titleSubtitleSpacingRatio,
      sectionGapRatio: sectionGapRatio ?? this.sectionGapRatio,
      screenshotCornerRadiusRatio:
          screenshotCornerRadiusRatio ?? this.screenshotCornerRadiusRatio,
      screenshotShadowDyRatio:
          screenshotShadowDyRatio ?? this.screenshotShadowDyRatio,
      screenshotShadowBlurRatio:
          screenshotShadowBlurRatio ?? this.screenshotShadowBlurRatio,
      screenshotBorderWidthRatio:
          screenshotBorderWidthRatio ?? this.screenshotBorderWidthRatio,
      screenshotHeightMinRatio:
          screenshotHeightMinRatio ?? this.screenshotHeightMinRatio,
      screenshotFitMode: screenshotFitMode ?? this.screenshotFitMode,
      screenshotTopOnlyRounded:
          screenshotTopOnlyRounded ?? this.screenshotTopOnlyRounded,
      deviceFrameEnabled: deviceFrameEnabled ?? this.deviceFrameEnabled,
      deviceFrameColor: deviceFrameColor ?? this.deviceFrameColor,
      deviceFrameThicknessRatio:
          deviceFrameThicknessRatio ?? this.deviceFrameThicknessRatio,
      deviceScreenInsetXRatio:
          deviceScreenInsetXRatio ?? this.deviceScreenInsetXRatio,
      deviceScreenInsetYRatio:
          deviceScreenInsetYRatio ?? this.deviceScreenInsetYRatio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoverLayout &&
        other.backgroundStyle == backgroundStyle &&
        other.showAmbientShapes == showAmbientShapes &&
        other.topMarginRatio == topMarginRatio &&
        other.sideMarginRatio == sideMarginRatio &&
        other.titleSubtitleSpacingRatio == titleSubtitleSpacingRatio &&
        other.sectionGapRatio == sectionGapRatio &&
        other.screenshotCornerRadiusRatio == screenshotCornerRadiusRatio &&
        other.screenshotShadowDyRatio == screenshotShadowDyRatio &&
        other.screenshotShadowBlurRatio == screenshotShadowBlurRatio &&
        other.screenshotBorderWidthRatio == screenshotBorderWidthRatio &&
        other.screenshotHeightMinRatio == screenshotHeightMinRatio &&
        other.screenshotFitMode == screenshotFitMode &&
        other.screenshotTopOnlyRounded == screenshotTopOnlyRounded &&
        other.deviceFrameEnabled == deviceFrameEnabled &&
        other.deviceFrameColor == deviceFrameColor &&
        other.deviceFrameThicknessRatio == deviceFrameThicknessRatio &&
        other.deviceScreenInsetXRatio == deviceScreenInsetXRatio &&
        other.deviceScreenInsetYRatio == deviceScreenInsetYRatio;
  }

  @override
  int get hashCode => Object.hash(
    backgroundStyle,
    showAmbientShapes,
    topMarginRatio,
    sideMarginRatio,
    titleSubtitleSpacingRatio,
    sectionGapRatio,
    screenshotCornerRadiusRatio,
    screenshotShadowDyRatio,
    screenshotShadowBlurRatio,
    screenshotBorderWidthRatio,
    screenshotHeightMinRatio,
    screenshotFitMode,
    screenshotTopOnlyRounded,
    deviceFrameEnabled,
    deviceFrameColor,
    deviceFrameThicknessRatio,
    deviceScreenInsetXRatio,
    deviceScreenInsetYRatio,
  );
}

class CoverLayoutPresets {
  static const CoverLayout classicGradient = CoverLayout();

  static const CoverLayout editorialLightPhone = CoverLayout(
    backgroundStyle: CoverBackgroundStyle.softLight,
    showAmbientShapes: false,
    topMarginRatio: 0.07,
    sideMarginRatio: 0.08,
    titleSubtitleSpacingRatio: 0.012,
    sectionGapRatio: 0.028,
    screenshotCornerRadiusRatio: 0.125,
    screenshotShadowDyRatio: 0.01,
    screenshotShadowBlurRatio: 0.03,
    screenshotBorderWidthRatio: 0.004,
    screenshotHeightMinRatio: 0.55,
    screenshotFitMode: ScreenshotFitMode.coverTopCenter,
    screenshotTopOnlyRounded: false,
    deviceFrameEnabled: true,
    deviceFrameColor: Color(0xFF06070A),
    deviceFrameThicknessRatio: 0.024,
    deviceScreenInsetXRatio: 1.35,
    deviceScreenInsetYRatio: 1.45,
  );

  static const List<CoverLayoutOption> options = [
    CoverLayoutOption(id: 'classic', label: '经典渐变', layout: classicGradient),
    CoverLayoutOption(
      id: 'editorial_light',
      label: '轻杂志风',
      layout: editorialLightPhone,
    ),
  ];
}

class CoverLayoutOption {
  final String id;
  final String label;
  final CoverLayout layout;

  const CoverLayoutOption({
    required this.id,
    required this.label,
    required this.layout,
  });
}
