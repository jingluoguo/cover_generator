import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controller/cover_generator_controller.dart';
import 'cover_generator_page.dart';

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

  const CoverCaptureWrapper({
    super.key,
    required this.child,
    this.showButton = true,
    this.icon = Icons.camera_alt_rounded,
    this.buttonColor,
    this.buttonSize = 48,
    this.backgroundColor,
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
              ? ColoredBox(
                  color: widget.backgroundColor!,
                  child: widget.child,
                )
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
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 2.0);
    _controller.setScreenshot(image);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoverGeneratorPage(controller: _controller),
      ),
    );
  }
}
