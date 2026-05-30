/// Predefined size presets for promotional cover images.
class CoverPreset {
  final String label;
  final double width;
  final double height;
  final String description;

  const CoverPreset({
    required this.label,
    required this.width,
    required this.height,
    required this.description,
  });

  double get aspectRatio => width / height;
}
