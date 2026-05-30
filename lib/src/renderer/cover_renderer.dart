import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/cover_config.dart';

/// Canvas-based renderer that produces promotional cover images.
///
/// Uses [ui.PictureRecorder] + [Canvas] for deterministic, high-quality output.
/// No widget tree or Flutter rendering pipeline involved.
class CoverRenderer {
  static const String _fontFamily = 'HarmonyOS';

  /// Render a cover image from the given [config].
  /// Returns PNG-encoded bytes at the target resolution.
  static Future<Uint8List> render(CoverConfig config) async {
    final w = config.width;
    final h = config.height;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    _paintBackground(canvas, w, h, config.startColor, config.endColor);
    _paintAmbientShapes(canvas, w, h, config.startColor, config.endColor);

    // Layout regions
    final topMargin = h * 0.04;
    final sideMargin = w * 0.07;
    final titleAreaHeight = h * 0.12;
    final gap = h * 0.02;

    // Calculate footer height based on actual text length
    final footerFontSize = w * 0.025;
    double bottomAreaHeight = 0;
    if (config.footerText != null && config.footerText!.isNotEmpty) {
      final footerParagraph =
          (ui.ParagraphBuilder(
                  ui.ParagraphStyle(
                    fontFamily: _fontFamily,
                    fontSize: footerFontSize,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    textAlign: ui.TextAlign.center,
                    height: 1.3,
                  ),
                )
                ..pushStyle(
                  ui.TextStyle(
                    color: Colors.white,
                    fontFamily: _fontFamily,
                    fontSize: footerFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                )
                ..addText(config.footerText!))
              .build()
            ..layout(ui.ParagraphConstraints(width: w - sideMargin * 2));
      bottomAreaHeight =
          footerParagraph.height + h * 0.04; // text height + padding
    }

    final screenshotArea = Rect.fromLTWH(
      sideMargin,
      topMargin + titleAreaHeight + gap,
      w - sideMargin * 2,
      h - topMargin - titleAreaHeight - bottomAreaHeight - gap,
    );

    // Title — centered with letter spacing
    final titleFontSize = w * 0.065;
    _drawText(
      canvas,
      text: config.title,
      rect: Rect.fromLTWH(
        sideMargin,
        topMargin,
        w - sideMargin * 2,
        titleAreaHeight * 0.55,
      ),
      fontSize: titleFontSize,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      maxLines: 2,
      lineHeight: 1.15,
      textAlign: TextAlign.center,
    );

    // Subtitle — centered, with spacing from title
    final subtitleFontSize = w * 0.03;
    _drawText(
      canvas,
      text: config.subtitle,
      rect: Rect.fromLTWH(
        sideMargin,
        topMargin + titleAreaHeight * 0.6,
        w - sideMargin * 2,
        titleAreaHeight * 0.4,
      ),
      fontSize: subtitleFontSize,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.85),
      maxLines: 2,
      lineHeight: 1.4,
      textAlign: TextAlign.center,
    );

    // Screenshot area
    if (config.screenshot != null) {
      _drawScreenshot(canvas, config.screenshot!, screenshotArea);
    } else {
      _drawPlaceholder(canvas, screenshotArea);
    }

    // Footer
    if (config.footerText != null && config.footerText!.isNotEmpty) {
      _drawText(
        canvas,
        text: config.footerText!,
        rect: Rect.fromLTWH(
          sideMargin,
          h - bottomAreaHeight,
          w - sideMargin * 2,
          bottomAreaHeight,
        ),
        fontSize: footerFontSize,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.7),
        maxLines: 2,
        textAlign: TextAlign.center,
      );
    }

    return _endRecording(recorder, w.toInt(), h.toInt());
  }

  // ─── Background ───

  static void _paintBackground(
    Canvas canvas,
    double w,
    double h,
    Color startColor,
    Color endColor,
  ) {
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
      // ignore: prefer_const_constructors
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.1);

    softPaint.color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(w * 0.15, h * 0.15), w * 0.2, softPaint);

    softPaint.color = startColor.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(w * 0.85, h * 0.18), w * 0.18, softPaint);

    softPaint.color = endColor.withValues(alpha: 0.22);
    canvas.drawCircle(Offset(w * 0.12, h * 0.88), w * 0.16, softPaint);

    // Decorative rounded rectangles
    final accentPaint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.82, h * 0.7, w * 0.06, h * 0.12),
        Radius.circular(w * 0.03),
      ),
      accentPaint,
    );
    canvas.save();
    canvas.translate(w * 0.9, h * 0.3);
    canvas.rotate(-math.pi / 9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.08, height: h * 0.1),
        Radius.circular(w * 0.03),
      ),
      accentPaint,
    );
    canvas.restore();
  }

  // ─── Screenshot ───

  static void _drawScreenshot(Canvas canvas, ui.Image image, Rect area) {
    final radius = area.width * 0.035;
    // Only round top corners, bottom is square (flush with canvas bottom).
    final rrect = RRect.fromRectAndCorners(
      area,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );

    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Clip and draw image
    canvas.save();
    canvas.clipRRect(rrect);

    // Scale to fill width, top-align. Bottom overflows and gets clipped.
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    final scale = area.width / imgW;
    final drawW = area.width;
    final drawH = imgH * scale;
    final dx = area.left;
    final dy = area.top;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, imgW, imgH),
      Rect.fromLTWH(dx, dy, drawW, drawH),
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();

    // Border (top only)
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.2),
    );
  }

  static void _drawPlaceholder(Canvas canvas, Rect area) {
    final borderRadius = area.width * 0.035;
    final rrect = RRect.fromRectAndRadius(area, Radius.circular(borderRadius));

    // Semi-transparent background
    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white.withValues(alpha: 0.1),
    );

    // Border
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.2),
    );

    // Placeholder text
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

  // ─── Text ───

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

  // ─── Finalize ───

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
