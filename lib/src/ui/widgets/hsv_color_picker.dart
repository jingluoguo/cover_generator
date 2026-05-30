import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A simple HSV color picker with hue slider, saturation/value gradient square,
/// and a preview of the selected color.
class HsvColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final String label;

  const HsvColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.label = '选择颜色',
  });

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            // Color preview
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _hsv.toColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Saturation x Value gradient square
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = 160.0;
            return GestureDetector(
              onPanStart: (d) => _updateSV(d.localPosition, width, height),
              onPanUpdate: (d) => _updateSV(d.localPosition, width, height),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  painter: _SVPainter(hue: _hsv.hue),
                  child: Stack(
                    children: [
                      Positioned(
                        left: _hsv.saturation * width - 8,
                        top: (1 - _hsv.value) * height - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // Hue slider
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              onPanStart: (d) => _updateHue(d.localPosition.dx, width),
              onPanUpdate: (d) => _updateHue(d.localPosition.dx, width),
              child: Container(
                width: width,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFF00FF),
                      Color(0xFF0000FF),
                      Color(0xFF00FFFF),
                      Color(0xFF00FF00),
                      Color(0xFFFFFF00),
                      Color(0xFFFF0000),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: (_hsv.hue / 360) * width - 8,
                      top: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _updateSV(Offset pos, double width, double height) {
    final s = (pos.dx / width).clamp(0.0, 1.0);
    final v = (1 - pos.dy / height).clamp(0.0, 1.0);
    setState(() {
      _hsv = _hsv.withSaturation(s).withValue(v);
    });
    widget.onColorChanged(_hsv.toColor());
  }

  void _updateHue(double dx, double width) {
    final h = (dx / width * 360).clamp(0.0, 360.0);
    setState(() {
      _hsv = _hsv.withHue(h);
    });
    widget.onColorChanged(_hsv.toColor());
  }
}

/// Paints the saturation (x-axis) x value (y-axis) gradient for a given hue.
class _SVPainter extends CustomPainter {
  final double hue;

  _SVPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    // White to hue color (horizontal)
    final hGradient = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [Colors.white, HSVColor.fromAHSV(1, hue, 1, 1).toColor()],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = hGradient,
    );

    // Transparent to black (vertical)
    final vGradient = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.height),
      [Colors.transparent, Colors.black],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = vGradient,
    );
  }

  @override
  bool shouldRepaint(_SVPainter oldDelegate) => oldDelegate.hue != hue;
}
