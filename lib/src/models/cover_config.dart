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

  const CoverConfig({
    required this.title,
    required this.subtitle,
    required this.width,
    required this.height,
    required this.startColor,
    required this.endColor,
    this.screenshot,
    this.footerText,
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
    );
  }
}
