import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Displays a generated cover image with aspect-ratio-preserving scaling.
class CoverPreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final double aspectRatio;

  const CoverPreview({
    super.key,
    required this.imageBytes,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: imageBytes != null
            ? Image.memory(imageBytes!, fit: BoxFit.cover)
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮生成',
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
