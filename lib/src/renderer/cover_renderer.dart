import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/cover_config.dart';

/// Canvas-based renderer that produces promotional cover images.
class CoverRenderer {
  static const String _defaultFontFamily = 'HarmonyOS';

  static Future<Uint8List> render(CoverConfig config) async {
    final w = config.width;
    final h = config.height;
    final layout = config.layout;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    _paintBackground(canvas, w, h, config.startColor, config.endColor, layout);
    if (layout.showAmbientShapes) {
      _paintAmbientShapes(canvas, w, h, config.startColor, config.endColor);
    }

    final topMargin = h * layout.topMarginRatio;
    final sideMargin = w * layout.sideMarginRatio;
    final gap = h * layout.sectionGapRatio;

    final baseSize = math.min(w, h);
    final titleFontSize = baseSize * 0.065;
    final subtitleFontSize = baseSize * 0.03;
    final titleContentWidth = w - sideMargin * 2;

    final titleColor =
        layout.backgroundStyle == CoverBackgroundStyle.softLight
            ? const Color(0xFF111111)
            : Colors.white;
    final subtitleColor =
        layout.backgroundStyle == CoverBackgroundStyle.softLight
            ? const Color(0xFF6F747C)
            : Colors.white.withValues(alpha: 0.85);

    final titleParagraph = _buildParagraph(
      text: config.title,
      width: titleContentWidth,
      fontSize: titleFontSize,
      fontWeight: FontWeight.w900,
      maxLines: 2,
      lineHeight: 1.15,
      textAlign: ui.TextAlign.center,
      color: titleColor,
      fontFamily: config.titleFontFamily ?? config.fontFamily,
      fontPackage: config.fontPackage,
    );

    final subtitleParagraph = _buildParagraph(
      text: config.subtitle,
      width: titleContentWidth,
      fontSize: subtitleFontSize,
      fontWeight: FontWeight.w400,
      maxLines: 2,
      lineHeight: 1.4,
      textAlign: ui.TextAlign.center,
      color: subtitleColor,
      fontFamily: config.subtitleFontFamily ?? config.fontFamily,
      fontPackage: config.fontPackage,
    );

    final titleHeight = titleParagraph.height;
    final subtitleHeight = config.subtitle.isNotEmpty ? subtitleParagraph.height : 0;
    final titleSpacing =
        config.subtitle.isNotEmpty ? h * layout.titleSubtitleSpacingRatio : 0.0;
    final titleAreaHeight = titleHeight + subtitleHeight + titleSpacing;

    final footerFontSize = w * 0.025;
    double bottomAreaHeight = 0;
    ui.Paragraph? footerParagraph;
    if (config.footerText != null && config.footerText!.isNotEmpty) {
      footerParagraph = _buildParagraph(
        text: config.footerText!,
        width: w - sideMargin * 2,
        fontSize: footerFontSize,
        fontWeight: FontWeight.w600,
        maxLines: 2,
        lineHeight: 1.3,
        textAlign: ui.TextAlign.center,
        color: subtitleColor,
        fontFamily: config.footerFontFamily ?? config.fontFamily,
        fontPackage: config.fontPackage,
      );
      bottomAreaHeight = footerParagraph.height + h * 0.04;
    }

    final screenshotTop = topMargin + titleAreaHeight + gap;
    final screenshotHeightRaw = h - screenshotTop - bottomAreaHeight - gap;
    final screenshotHeight = math.max(
      screenshotHeightRaw,
      h * layout.screenshotHeightMinRatio,
    );
    final screenshotArea = Rect.fromLTWH(
      sideMargin,
      screenshotTop,
      w - sideMargin * 2,
      screenshotHeight,
    );

    canvas.drawParagraph(titleParagraph, Offset(sideMargin, topMargin));

    if (config.subtitle.isNotEmpty) {
      final subtitleTop = topMargin + titleHeight + titleSpacing;
      canvas.drawParagraph(subtitleParagraph, Offset(sideMargin, subtitleTop));
    }

    if (config.screenshot != null) {
      _drawScreenshot(canvas, config.screenshot!, screenshotArea, layout);
    } else {
      _drawPlaceholder(canvas, screenshotArea, layout);
    }

    if (footerParagraph != null) {
      canvas.drawParagraph(
        footerParagraph,
        Offset(sideMargin, h - bottomAreaHeight + h * 0.015),
      );
    }

    return _endRecording(recorder, w.toInt(), h.toInt());
  }

  static void _paintBackground(
    Canvas canvas,
    double w,
    double h,
    Color startColor,
    Color endColor,
    CoverLayout layout,
  ) {
    if (layout.backgroundStyle == CoverBackgroundStyle.softLight) {
      final rect = Rect.fromLTWH(0, 0, w, h);
      canvas.drawRect(rect, Paint()..color = const Color(0xFFF2F5F7));
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(w * 0.5, h * 0.3),
            w * 0.95,
            [
              Colors.white.withValues(alpha: 0.86),
              const Color(0xFFE4EBF0).withValues(alpha: 0.92),
            ],
          ),
      );
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(const Offset(0, 0), Offset(w, h), [
          startColor,
          endColor,
        ]),
    );
  }

  static void _paintAmbientShapes(
    Canvas canvas,
    double w,
    double h,
    Color startColor,
    Color endColor,
  ) {
    final softPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.1);

    softPaint.color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(w * 0.15, h * 0.15), w * 0.2, softPaint);

    softPaint.color = startColor.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(w * 0.85, h * 0.18), w * 0.18, softPaint);

    softPaint.color = endColor.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(w * 0.12, h * 0.88), w * 0.16, softPaint);
  }

  static void _drawScreenshot(
    Canvas canvas,
    ui.Image image,
    Rect area,
    CoverLayout layout,
  ) {
    final frameThickness =
        layout.deviceFrameEnabled ? area.width * layout.deviceFrameThicknessRatio : 0.0;
    final insetX = frameThickness * layout.deviceScreenInsetXRatio;
    final insetY = frameThickness * layout.deviceScreenInsetYRatio;
    final outerRect = area;
    final innerRect = layout.deviceFrameEnabled
        ? Rect.fromLTWH(
            area.left + insetX,
            area.top + insetY,
            math.max(1.0, area.width - insetX * 2),
            math.max(1.0, area.height - insetY * 2),
          )
        : area;

    final radius = math.max(
      innerRect.width * layout.screenshotCornerRadiusRatio,
      innerRect.width * 0.03,
    );
    final rrect =
        layout.screenshotTopOnlyRounded
            ? RRect.fromRectAndCorners(
              innerRect,
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            )
            : RRect.fromRectAndRadius(innerRect, Radius.circular(radius));

    if (layout.deviceFrameEnabled) {
      final frameRadius = radius + frameThickness * 1.6;
      final frameRRect = RRect.fromRectAndRadius(
        outerRect,
        Radius.circular(frameRadius),
      );
      canvas.drawRRect(frameRRect, Paint()..color = layout.deviceFrameColor);
    }

    canvas.drawRRect(
      rrect.shift(Offset(0, area.height * layout.screenshotShadowDyRatio)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, area.width * layout.screenshotShadowBlurRatio),
    );

    canvas.save();
    canvas.clipRRect(rrect);

    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    double drawW;
    double drawH;
    double dx;
    double dy;
    switch (layout.screenshotFitMode) {
      case ScreenshotFitMode.containTopCenter:
        final scale = math.min(innerRect.width / imgW, innerRect.height / imgH);
        drawW = imgW * scale;
        drawH = imgH * scale;
        dx = innerRect.left + (innerRect.width - drawW) / 2;
        dy = innerRect.top;
        break;
      case ScreenshotFitMode.containCenter:
        final scale = math.min(innerRect.width / imgW, innerRect.height / imgH);
        drawW = imgW * scale;
        drawH = imgH * scale;
        dx = innerRect.left + (innerRect.width - drawW) / 2;
        dy = innerRect.top + (innerRect.height - drawH) / 2;
        break;
      case ScreenshotFitMode.coverTopCenter:
        final scale = innerRect.width / imgW;
        drawW = innerRect.width;
        drawH = imgH * scale;
        dx = innerRect.left;
        dy = innerRect.top;
        break;
    }

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imgW, imgH),
      Rect.fromLTWH(dx, dy, drawW, drawH),
      Paint()..filterQuality = FilterQuality.high,
    );

    if (
        layout.deviceIslandEnabled &&
        !(layout.statusBarEnabled && layout.statusBarStyle == CoverStatusBarStyle.ios)) {
      _drawDeviceIsland(canvas, innerRect, layout);
    }

    if (layout.statusBarEnabled) {
      _drawStatusBar(canvas, innerRect, layout);
    }

    if (layout.homeIndicatorEnabled) {
      _drawHomeIndicator(canvas, innerRect, layout);
    }

    canvas.restore();

    // No inner stroke for framed layout to avoid corner arc artifacts.
    if (!layout.deviceFrameEnabled) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, area.width * layout.screenshotBorderWidthRatio * 0.7)
          ..color = Colors.white.withValues(alpha: 0.16),
      );
    }
  }

  static void _drawPlaceholder(Canvas canvas, Rect area, CoverLayout layout) {
    final borderRadius = area.width * layout.screenshotCornerRadiusRatio;
    final rrect = RRect.fromRectAndRadius(area, Radius.circular(borderRadius));

    canvas.drawRRect(rrect, Paint()..color = Colors.white.withValues(alpha: 0.1));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, area.width * layout.screenshotBorderWidthRatio)
        ..color = Colors.white.withValues(alpha: 0.2),
    );

    _drawText(
      canvas,
      text: '📱',
      rect: Rect.fromCenter(
        center: area.center,
        width: area.width * 0.3,
        height: area.height * 0.2,
      ),
      fontSize: area.width * 0.12,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.3),
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }

  static void _drawDeviceIsland(
    Canvas canvas,
    Rect screenRect,
    CoverLayout layout,
  ) {
    final islandWidth = screenRect.width * layout.deviceIslandWidthRatio;
    final islandHeight = screenRect.height * layout.deviceIslandHeightRatio;
    final islandCenterY =
        screenRect.top + screenRect.height * layout.deviceIslandTopInsetRatio;
    final islandRect = Rect.fromCenter(
      center: Offset(screenRect.center.dx, islandCenterY),
      width: islandWidth,
      height: islandHeight,
    );
    final islandRadius = islandHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(islandRect, Radius.circular(islandRadius)),
      Paint()..color = const Color(0xFF05070B),
    );
  }

  static void _drawStatusBar(
    Canvas canvas,
    Rect screenRect,
    CoverLayout layout,
  ) {
    final statusHeight = screenRect.height * layout.statusBarHeightRatio;
    final rect = Rect.fromLTWH(
      screenRect.left,
      screenRect.top,
      screenRect.width,
      statusHeight,
    );

    if (layout.statusBarStyle == CoverStatusBarStyle.ios) {
      _drawIosStatusBar(
        canvas,
        rect,
        screenRect,
        layout,
        layout.statusBarForegroundColor,
        layout.statusBarTimeText,
      );
    } else {
      canvas.drawRect(
        rect,
        Paint()..color = layout.statusBarBackgroundColor,
      );
      _drawAndroidStatusBar(
        canvas,
        rect,
        layout.statusBarForegroundColor,
        layout.statusBarTimeText,
      );
    }
  }

  static void _drawIosStatusBar(
    Canvas canvas,
    Rect rect,
    Rect screenRect,
    CoverLayout layout,
    Color iconColor,
    String time,
  ) {
    final statusHeight = rect.height;
    final width = rect.width;
    final iconSize = statusHeight * 0.40;
    final centerY = screenRect.top + screenRect.height * layout.deviceIslandTopInsetRatio;
    final leftPadding = math.max(24.0, width * 0.055);
    final rightPadding = math.max(20.0, width * 0.05);
    final islandWidth = screenRect.width * layout.deviceIslandWidthRatio;
    final islandHeight = screenRect.height * layout.deviceIslandHeightRatio;

    final timeStyle = TextStyle(
      color: iconColor,
      fontSize: statusHeight * 0.34,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );
    final timePainter = TextPainter(
      text: TextSpan(text: time, style: timeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    timePainter.paint(
      canvas,
      Offset(rect.left + leftPadding, centerY - timePainter.height / 2),
    );

    if (layout.deviceIslandEnabled) {
      final islandRect = Rect.fromCenter(
        center: Offset(screenRect.center.dx, centerY),
        width: islandWidth,
        height: islandHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          islandRect,
          Radius.circular(islandHeight / 2),
        ),
        Paint()..color = const Color(0xFF05070B),
      );
    }

    final batteryWidth = iconSize * 1.28;
    final batteryHeight = iconSize * 0.62;
    final batteryRight = rect.right - rightPadding;
    final batteryTop = centerY - batteryHeight / 2;
    final batteryLeft = batteryRight - batteryWidth;
    final batteryRect = Rect.fromLTWH(
      batteryLeft,
      batteryTop,
      batteryWidth,
      batteryHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        batteryRect,
        Radius.circular(batteryHeight * 0.25),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = iconColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          batteryLeft + 2,
          batteryTop + 2,
          (batteryWidth - 5) * 0.85,
          batteryHeight - 4,
        ),
        Radius.circular(batteryHeight * 0.15),
      ),
      Paint()..color = iconColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          batteryRight,
          batteryTop + batteryHeight * 0.25,
          batteryWidth * 0.08,
          batteryHeight * 0.5,
        ),
        Radius.circular(1),
      ),
      Paint()..color = iconColor,
    );

    final wifiRight = batteryLeft - iconSize * 1.15;
    _drawWifiIcon(canvas, Offset(wifiRight, centerY), iconSize * 1.05, iconColor);
  }

  static void _drawAndroidStatusBar(
    Canvas canvas,
    Rect rect,
    Color iconColor,
    String time,
  ) {
    final statusHeight = rect.height;
    final width = rect.width;
    final iconSize = statusHeight * 0.38;
    final centerY = rect.top + statusHeight / 2;
    final leftPadding = math.max(20.0, width * 0.05);
    final rightPadding = math.max(16.0, width * 0.045);

    final timeStyle = TextStyle(
      color: iconColor,
      fontSize: statusHeight * 0.38,
      fontWeight: FontWeight.w500,
    );
    final timePainter = TextPainter(
      text: TextSpan(text: time, style: timeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    timePainter.paint(
      canvas,
      Offset(rect.left + leftPadding, centerY - timePainter.height / 2),
    );

    final batteryWidth = iconSize * 1.1;
    final batteryHeight = iconSize * 0.55;
    final batteryRight = rect.right - rightPadding;
    final batteryTop = centerY - batteryHeight / 2;
    final batteryLeft = batteryRight - batteryWidth;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(batteryLeft, batteryTop, batteryWidth, batteryHeight),
        Radius.circular(batteryHeight * 0.2),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = iconColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          batteryLeft + 1.5,
          batteryTop + 1.5,
          (batteryWidth - 4) * 0.82,
          batteryHeight - 3,
        ),
        Radius.circular(batteryHeight * 0.1),
      ),
      Paint()..color = iconColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        batteryRight,
        batteryTop + batteryHeight * 0.22,
        batteryWidth * 0.06,
        batteryHeight * 0.56,
      ),
      Paint()..color = iconColor,
    );

    final wifiRight = batteryLeft - 14;
    _drawWifiIcon(canvas, Offset(wifiRight, centerY), iconSize * 1.1, iconColor);
  }

  static void _drawWifiIcon(
    Canvas canvas,
    Offset center,
    double size,
    Color iconColor,
  ) {
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.1
      ..strokeCap = StrokeCap.round;
    final radii = [size * 0.45, size * 0.32, size * 0.19];
    for (final r in radii) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx, center.dy + size * 0.15),
          radius: r,
        ),
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        paint,
      );
    }
    canvas.drawCircle(
      Offset(center.dx, center.dy + size * 0.15),
      size * 0.06,
      Paint()..color = iconColor,
    );
  }

  static void _drawHomeIndicator(
    Canvas canvas,
    Rect screenRect,
    CoverLayout layout,
  ) {
    final indicatorWidth = screenRect.width * layout.homeIndicatorWidthRatio;
    final indicatorHeight = screenRect.height * layout.homeIndicatorHeightRatio;
    final indicatorBottom =
        screenRect.bottom - screenRect.height * layout.homeIndicatorBottomInsetRatio;
    final indicatorRect = Rect.fromCenter(
      center: Offset(
        screenRect.center.dx,
        indicatorBottom - indicatorHeight / 2,
      ),
      width: indicatorWidth,
      height: indicatorHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        indicatorRect,
        Radius.circular(indicatorHeight / 2),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.85),
    );
  }

  static void _drawText(
    Canvas canvas, {
    required String text,
    required Rect rect,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required int maxLines,
    TextAlign textAlign = TextAlign.left,
    double lineHeight = 1.2,
  }) {
    if (text.isEmpty) return;
    final builder =
        ui.ParagraphBuilder(
          ui.ParagraphStyle(
            fontFamily: _defaultFontFamily,
            fontSize: fontSize,
            fontWeight: fontWeight,
            maxLines: maxLines,
            textAlign: _mapAlign(textAlign),
            height: lineHeight,
          ),
        )..pushStyle(
          ui.TextStyle(
            color: color,
            fontFamily: _defaultFontFamily,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        );
    builder.addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: rect.width));
    canvas.drawParagraph(paragraph, Offset(rect.left, rect.top));
  }

  static ui.Paragraph _buildParagraph({
    required String text,
    required double width,
    required double fontSize,
    required FontWeight fontWeight,
    required int maxLines,
    required double lineHeight,
    required ui.TextAlign textAlign,
    Color color = Colors.white,
    String? fontFamily,
    String? fontPackage,
  }) {
    final resolvedFontFamily =
        _resolveFontFamily(fontFamily: fontFamily, fontPackage: fontPackage) ??
        _defaultFontFamily;
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: resolvedFontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        maxLines: maxLines,
        textAlign: textAlign,
        height: lineHeight,
      ),
    )..pushStyle(
      ui.TextStyle(
        color: color,
        fontFamily: resolvedFontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    builder.addText(text);
    return builder.build()
      ..layout(ui.ParagraphConstraints(width: width));
  }

  static String? _resolveFontFamily({
    required String? fontFamily,
    required String? fontPackage,
  }) {
    final normalized = fontFamily?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final packageName = fontPackage?.trim();
    if (packageName == null || packageName.isEmpty) {
      return normalized;
    }
    if (normalized.startsWith('packages/')) {
      return normalized;
    }
    return 'packages/$packageName/$normalized';
  }

  static ui.TextAlign _mapAlign(TextAlign align) {
    return switch (align) {
      TextAlign.center => ui.TextAlign.center,
      TextAlign.right => ui.TextAlign.right,
      TextAlign.end => ui.TextAlign.end,
      TextAlign.justify => ui.TextAlign.justify,
      TextAlign.start => ui.TextAlign.start,
      _ => ui.TextAlign.left,
    };
  }

  static Future<Uint8List> _endRecording(
    ui.PictureRecorder recorder,
    int w,
    int h,
  ) async {
    final image = await recorder.endRecording().toImage(w, h);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
