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
  final CoverBackgroundStyle backgroundStyle;
  final bool showAmbientShapes;
  final double topMarginRatio;
  final double sideMarginRatio;
  final double titleSubtitleSpacingRatio;
  final double sectionGapRatio;
  final double screenshotCornerRadiusRatio;
  final double screenshotShadowDyRatio;
  final double screenshotShadowBlurRatio;
  final double screenshotBorderWidthRatio;
  final double screenshotHeightMinRatio;
  final ScreenshotFitMode screenshotFitMode;
  final bool screenshotTopOnlyRounded;
  final bool deviceFrameEnabled;
  final Color deviceFrameColor;
  final double deviceFrameThicknessRatio;
  final double deviceScreenInsetXRatio;
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
    sideMarginRatio: 0.06,
    titleSubtitleSpacingRatio: 0.012,
    sectionGapRatio: 0.028,
    screenshotCornerRadiusRatio: 0.08,
    screenshotShadowDyRatio: 0.01,
    screenshotShadowBlurRatio: 0.03,
    screenshotBorderWidthRatio: 0.004,
    screenshotHeightMinRatio: 0.55,
    screenshotFitMode: ScreenshotFitMode.containCenter,
    screenshotTopOnlyRounded: false,
    deviceFrameEnabled: true,
    deviceFrameColor: Color(0xFF06070A),
    deviceFrameThicknessRatio: 0.02,
    deviceScreenInsetXRatio: 0.02,
    deviceScreenInsetYRatio: 2.8,
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
