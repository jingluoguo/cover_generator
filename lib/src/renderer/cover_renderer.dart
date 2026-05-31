import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/cover_config.dart';

/// Canvas-based renderer that produces promotional cover images.
class CoverRenderer {
  static const String _fontFamily = 'HarmonyOS';

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
            fontFamily: _fontFamily,
            fontSize: fontSize,
            fontWeight: fontWeight,
            maxLines: maxLines,
            textAlign: _mapAlign(textAlign),
            height: lineHeight,
          ),
        )..pushStyle(
          ui.TextStyle(
            color: color,
            fontFamily: _fontFamily,
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
  }) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: _fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        maxLines: maxLines,
        textAlign: textAlign,
        height: lineHeight,
      ),
    )..pushStyle(
      ui.TextStyle(
        color: color,
        fontFamily: _fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    builder.addText(text);
    return builder.build()
      ..layout(ui.ParagraphConstraints(width: width));
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
