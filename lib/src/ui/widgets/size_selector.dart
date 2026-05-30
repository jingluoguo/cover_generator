import 'package:flutter/material.dart';

import '../../models/cover_preset.dart';

/// Horizontal chip list for selecting a size preset, with optional custom input.
class SizeSelector extends StatelessWidget {
  final List<CoverPreset> presets;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double? customWidth;
  final double? customHeight;
  final ValueChanged<double>? onCustomWidthChanged;
  final ValueChanged<double>? onCustomHeightChanged;

  const SizeSelector({
    super.key,
    required this.presets,
    required this.selectedIndex,
    required this.onSelect,
    this.customWidth,
    this.customHeight,
    this.onCustomWidthChanged,
    this.onCustomHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = selectedIndex >= presets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '尺寸',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length + 1, // +1 for "Custom"
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isSelected = selectedIndex == i;
              final label = i < presets.length ? presets[i].label : '自定义';
              return Theme(
                data: Theme.of(context).copyWith(
                  chipTheme: ChipThemeData(
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: const Color(0xFF667eea),
                    surfaceTintColor: Colors.transparent,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => onSelect(i),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        if (isCustom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: _dimDecoration('宽'),
                  controller: TextEditingController(
                    text: customWidth?.toInt().toString() ?? '',
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null) onCustomWidthChanged?.call(d);
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('×', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: _dimDecoration('高'),
                  controller: TextEditingController(
                    text: customHeight?.toInt().toString() ?? '',
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null) onCustomHeightChanged?.call(d);
                  },
                ),
              ),
            ],
          ),
        ],
        if (!isCustom) ...[
          const SizedBox(height: 6),
          Text(
            presets[selectedIndex].description,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _dimDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
    );
  }
}
