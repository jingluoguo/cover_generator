import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../controller/cover_generator_controller.dart';
import 'cover_generator_page.dart';

enum StatusBarStyle { ios, android }

/// A wrapper widget that captures its [child] as a screenshot and navigates
/// to the cover generator page.
///
/// ```dart
/// CoverCaptureWrapper(
///   showButton: true,
///   child: MyContent(),
/// )
/// ```
class CoverCaptureWrapper extends StatefulWidget {
  final Widget child;
  final bool showButton;
  final IconData icon;
  final Color? buttonColor;
  final double buttonSize;

  /// Background color applied inside the capture boundary.
  /// If null, no background is painted (transparent).
  final Color? backgroundColor;

  /// Whether to append a simulated status bar above the captured screenshot.
  final bool appendStatusBar;

  /// Background color of the simulated status bar.
  final Color statusBarColor;

  /// Color to use for status bar text and icons.
  final Color statusBarTextColor;

  /// Height of the appended status bar in pixels.
  final double statusBarHeight;

  /// Style of the simulated status bar.
  final StatusBarStyle statusBarStyle;

  /// Whether to use the real system status bar info (height, time).
  /// When true, [statusBarHeight] is ignored and the device's actual
  /// status bar padding is used. The current system time is displayed
  /// instead of the hardcoded "9:41".
  final bool useSystemStatusBar;

  const CoverCaptureWrapper({
    super.key,
    required this.child,
    this.showButton = true,
    this.icon = Icons.camera_alt_rounded,
    this.buttonColor,
    this.buttonSize = 48,
    this.backgroundColor,
    this.appendStatusBar = false,
    this.statusBarColor = const Color(0xFF0E1228),
    this.statusBarTextColor = Colors.white,
    this.statusBarHeight = 56,
    this.statusBarStyle = StatusBarStyle.ios,
    this.useSystemStatusBar = false,
  });

  @override
  State<CoverCaptureWrapper> createState() => _CoverCaptureWrapperState();
}

class _CoverCaptureWrapperState extends State<CoverCaptureWrapper> {
  final _boundaryKey = GlobalKey();
  late final CoverGeneratorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CoverGeneratorController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Content fills the available space.
        RepaintBoundary(
          key: _boundaryKey,
          child: widget.backgroundColor != null
              ? ColoredBox(color: widget.backgroundColor!, child: widget.child)
              : widget.child,
        ),

        // Floating capture button — always on top of content.
        if (widget.showButton)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: GestureDetector(
              onTap: _captureAndNavigate,
              child: Container(
                width: widget.buttonSize,
                height: widget.buttonSize,
                decoration: BoxDecoration(
                  color: widget.buttonColor ?? const Color(0xFF667eea),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.buttonColor ?? const Color(0xFF667eea))
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.buttonSize * 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _captureAndNavigate() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 2.0);
    final screenshot = widget.appendStatusBar
        ? await _buildScreenshotWithStatusBar(image)
        : image;

    if (widget.appendStatusBar) {
      image.dispose();
    }

    _controller.setScreenshot(screenshot);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoverGeneratorPage(controller: _controller),
      ),
    );
  }

  /// Returns the status bar height to use for the screenshot.
  double get _effectiveStatusBarHeight {
    if (widget.useSystemStatusBar) {
      return MediaQuery.of(context).padding.top;
    }
    return widget.statusBarHeight;
  }

  /// Returns the formatted time string to display in the status bar.
  String get _effectiveTime {
    if (widget.useSystemStatusBar) {
      final now = DateTime.now();
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '9:41';
  }

  Future<ui.Image> _buildScreenshotWithStatusBar(ui.Image image) async {
    final width = image.width;
    final height = image.height;
    final statusHeight = _effectiveStatusBarHeight;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );

    // Draw original screenshot first.
    canvas.drawImage(
      image,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.high,
    );

    // Status bar background — overlay on top of the screenshot.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), statusHeight),
      Paint()..color = widget.statusBarColor,
    );

    if (widget.statusBarStyle == StatusBarStyle.ios) {
      _drawIosStatusBar(
        canvas,
        width,
        statusHeight,
        widget.statusBarTextColor,
        _effectiveTime,
      );
    } else {
      _drawAndroidStatusBar(
        canvas,
        width,
        statusHeight,
        widget.statusBarTextColor,
        _effectiveTime,
      );
    }

    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

  static void _drawIosStatusBar(
    Canvas canvas,
    int width,
    double statusHeight,
    Color iconColor,
    String time,
  ) {
    final iconSize = statusHeight * 0.35;
    final centerY = statusHeight / 2;
    final leftPadding = 20.0;
    final rightPadding = 16.0;

    // Left: Signal bars (4 bars with increasing height, bottom-aligned).
    final barWidth = iconSize * 0.18;
    final barGap = iconSize * 0.12;
    final barMaxHeight = iconSize * 0.75;
    final barBottom = centerY + barMaxHeight * 0.4;
    for (var i = 0; i < 4; i++) {
      final barHeight = barMaxHeight * (0.3 + 0.23 * i);
      final barLeft = leftPadding + i * (barWidth + barGap);
      final barTop = barBottom - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
          Radius.circular(barWidth * 0.35),
        ),
        Paint()..color = iconColor,
      );
    }

    // Left: Carrier text or "LTE"/"5G" after signal bars.
    final carrierLeft = leftPadding + 4 * (barWidth + barGap) + 6;
    final carrierStyle = TextStyle(
      color: iconColor,
      fontSize: statusHeight * 0.32,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
    );
    final carrierPainter = TextPainter(
      text: TextSpan(text: 'LTE', style: carrierStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    carrierPainter.paint(
      canvas,
      Offset(carrierLeft, (statusHeight - carrierPainter.height) / 2),
    );

    // Center: Time (bold, centered).
    final timeStyle = TextStyle(
      color: iconColor,
      fontSize: statusHeight * 0.45,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
    final timePainter = TextPainter(
      text: TextSpan(text: time, style: timeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    timePainter.paint(
      canvas,
      Offset(
        (width - timePainter.width) / 2,
        (statusHeight - timePainter.height) / 2,
      ),
    );

    // Right: Battery icon.
    final batteryWidth = iconSize * 1.2;
    final batteryHeight = iconSize * 0.55;
    final batteryRight = width.toDouble() - rightPadding;
    final batteryTop = (statusHeight - batteryHeight) / 2;
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
    // Battery fill (green for charged look).
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
    // Battery nub.
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

    // Right: Wi-Fi icon (left of battery).
    final wifiRight = batteryLeft - 12;
    _drawIosWifiIcon(canvas, Offset(wifiRight, centerY), iconSize * 1.1, iconColor);
  }

  static void _drawIosWifiIcon(
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
    // Three arcs for Wi-Fi signal.
    final radii = [size * 0.45, size * 0.32, size * 0.19];
    for (final r in radii) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + size * 0.15), radius: r),
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        paint,
      );
    }
    // Center dot.
    canvas.drawCircle(
      Offset(center.dx, center.dy + size * 0.15),
      size * 0.06,
      Paint()..color = iconColor,
    );
  }

  static void _drawAndroidStatusBar(
    Canvas canvas,
    int width,
    double statusHeight,
    Color iconColor,
    String time,
  ) {
    final iconSize = statusHeight * 0.38;
    final centerY = statusHeight / 2;
    final leftPadding = 16.0;
    final rightPadding = 12.0;

    // Left: Time.
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
      Offset(leftPadding, (statusHeight - timePainter.height) / 2),
    );

    // Right: Battery icon.
    final batteryWidth = iconSize * 1.1;
    final batteryHeight = iconSize * 0.55;
    final batteryRight = width.toDouble() - rightPadding;
    final batteryTop = (statusHeight - batteryHeight) / 2;
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
    // Battery fill.
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
    // Battery nub.
    canvas.drawRect(
      Rect.fromLTWH(
        batteryRight,
        batteryTop + batteryHeight * 0.22,
        batteryWidth * 0.06,
        batteryHeight * 0.56,
      ),
      Paint()..color = iconColor,
    );

    // Right: Wi-Fi icon (left of battery).
    final wifiRight = batteryLeft - 14;
    _drawAndroidWifiIcon(canvas, Offset(wifiRight, centerY), iconSize * 1.1, iconColor);
  }

  static void _drawAndroidWifiIcon(
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
        Rect.fromCircle(center: Offset(center.dx, center.dy + size * 0.1), radius: r),
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        paint,
      );
    }
    canvas.drawCircle(
      Offset(center.dx, center.dy + size * 0.1),
      size * 0.06,
      Paint()..color = iconColor,
    );
  }
}
