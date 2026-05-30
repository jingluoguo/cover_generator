import 'package:flutter/material.dart';

import '../controller/cover_generator_controller.dart';

/// Full-screen preview of the generated cover image with save/share actions.
class GeneratedResultPage extends StatefulWidget {
  final CoverGeneratorController controller;

  const GeneratedResultPage({super.key, required this.controller});

  @override
  State<GeneratedResultPage> createState() => _GeneratedResultPageState();
}

class _GeneratedResultPageState extends State<GeneratedResultPage> {
  CoverGeneratorController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onUpdate);
  }

  @override
  void dispose() {
    c.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '重新编辑',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: c.generatedBytes == null
                    ? const Text(
                        '无生成内容',
                        style: TextStyle(color: Colors.white54),
                      )
                    : InteractiveViewer(
                        maxScale: 3.0,
                        child: Image.memory(c.generatedBytes!, fit: BoxFit.contain),
                      ),
              ),
            ),
          ),

          // Info bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${c.effectiveWidth.toInt()} × ${c.effectiveHeight.toInt()}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const Spacer(),
                const Text(
                  'PNG',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // Action buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.ios_share_rounded,
                      label: '分享',
                      onTap: c.shareImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.save_alt_rounded,
                      label: '保存',
                      onTap: c.shareImage,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF667eea)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
