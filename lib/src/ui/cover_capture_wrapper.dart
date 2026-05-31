import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../controller/cover_generator_controller.dart';
import '../models/cover_config.dart';
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

  /// Initial layout style for the cover generator.
  final CoverLayout initialLayout;

  /// Whether to show layout selector chips in generator page.
  final bool enableLayoutSelector;

  /// Layout options available to end users.
  final List<CoverLayoutOption> layoutOptions;

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
    this.initialLayout = CoverLayoutPresets.classicGradient,
    this.enableLayoutSelector = true,
    this.layoutOptions = CoverLayoutPresets.options,
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
    _controller.updateLayout(
      widget.initialLayout.copyWith(
        statusBarEnabled: widget.appendStatusBar,
        statusBarStyle: switch (widget.statusBarStyle) {
          StatusBarStyle.ios => CoverStatusBarStyle.ios,
          StatusBarStyle.android => CoverStatusBarStyle.android,
        },
        statusBarBackgroundColor: widget.statusBarColor,
        statusBarForegroundColor: widget.statusBarTextColor,
        statusBarHeightRatio: widget.statusBarHeight / 900,
        statusBarTimeText: _effectiveTime,
      ),
    );
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
    _controller.setScreenshot(image);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoverGeneratorPage(
          controller: _controller,
          enableLayoutSelector: widget.enableLayoutSelector,
          layoutOptions: widget.layoutOptions,
        ),
      ),
    );
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

}
