import 'package:flutter/material.dart';

/// Title and subtitle text input fields for the cover.
class CoverTextInputs extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final TextEditingController footerController;

  const CoverTextInputs({
    super.key,
    required this.titleController,
    required this.subtitleController,
    required this.footerController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('标题'),
        const SizedBox(height: 6),
        TextField(
          controller: titleController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          decoration: _inputDecoration('输入封面标题'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildLabel('副标题'),
        const SizedBox(height: 6),
        TextField(
          controller: subtitleController,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: _inputDecoration('输入副标题'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildLabel('底部文字（可选）'),
        const SizedBox(height: 6),
        TextField(
          controller: footerController,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: _inputDecoration('App 名称或 Slogan'),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Colors.grey.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF667eea), width: 1.5),
      ),
    );
  }
}
