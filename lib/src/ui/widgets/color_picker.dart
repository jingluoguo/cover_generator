import 'package:flutter/material.dart';

import 'hsv_color_picker.dart';

/// Preset gradient color pairs for quick selection.
const List<List<Color>> kGradientPresets = [
  [Color(0xFF667eea), Color(0xFF764ba2)], // Purple Dream
  [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink Sunset
  [Color(0xFF4facfe), Color(0xFF00f2fe)], // Ocean Blue
  [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green Fresh
  [Color(0xFFfa709a), Color(0xFFfee140)], // Warm Glow
  [Color(0xFFa18cd1), Color(0xFFfbc2eb)], // Lavender
  [Color(0xFFfccb90), Color(0xFFd57eeb)], // Peach Purple
  [Color(0xFF0c3483), Color(0xFFa2b6df)], // Deep Blue
  [Color(0xFF000000), Color(0xFF434343)], // Dark Mono
  [Color(0xFF11998e), Color(0xFF38ef7d)], // Teal Green
];

class GradientColorPicker extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  final ValueChanged<int> onSelect;
  final ValueChanged<Color> onStartColorChanged;
  final ValueChanged<Color> onEndColorChanged;

  const GradientColorPicker({
    super.key,
    required this.startColor,
    required this.endColor,
    required this.onSelect,
    required this.onStartColorChanged,
    required this.onEndColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '渐变色',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kGradientPresets.length + 1, // +1 for custom
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              if (i < kGradientPresets.length) {
                final colors = kGradientPresets[i];
                final isSelected =
                    colors[0].toARGB32() == startColor.toARGB32() &&
                    colors[1].toARGB32() == endColor.toARGB32();
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors[0].withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }

              // Custom color button
              return GestureDetector(
                onTap: () => _showCustomColorPicker(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [startColor, endColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCustomColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomColorSheet(
        startColor: startColor,
        endColor: endColor,
        onStartChanged: onStartColorChanged,
        onEndChanged: onEndColorChanged,
      ),
    );
  }
}

class _CustomColorSheet extends StatefulWidget {
  final Color startColor;
  final Color endColor;
  final ValueChanged<Color> onStartChanged;
  final ValueChanged<Color> onEndChanged;

  const _CustomColorSheet({
    required this.startColor,
    required this.endColor,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  State<_CustomColorSheet> createState() => _CustomColorSheetState();
}

class _CustomColorSheetState extends State<_CustomColorSheet> {
  late Color _start;
  late Color _end;
  bool _editingStart = true;

  @override
  void initState() {
    super.initState();
    _start = widget.startColor;
    _end = widget.endColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),

          // Tab bar: start / end
          Row(
            children: [
              _tabButton('起始色', true),
              const SizedBox(width: 8),
              _tabButton('结束色', false),
              const Spacer(),
              // Preview
              Container(
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_start, _end],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // HSV picker
          HsvColorPicker(
            initialColor: _editingStart ? _start : _end,
            onColorChanged: (color) {
              setState(() {
                if (_editingStart) {
                  _start = color;
                } else {
                  _end = color;
                }
              });
            },
            label: _editingStart ? '起始色' : '结束色',
          ),
          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onStartChanged(_start);
                widget.onEndChanged(_end);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                '确定',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool isStart) {
    final isActive = _editingStart == isStart;
    return GestureDetector(
      onTap: () => setState(() => _editingStart = isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF667eea)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isStart ? _start : _end,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
