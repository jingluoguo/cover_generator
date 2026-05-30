import 'models/cover_preset.dart';

/// Built-in size presets for common app store promotional images.
const List<CoverPreset> kCoverPresets = [
  CoverPreset(
    label: 'iPhone 6.7"',
    width: 1290,
    height: 2796,
    description: 'App Store · iPhone 15 Pro Max',
  ),
  CoverPreset(
    label: 'iPhone 6.5"',
    width: 1284,
    height: 2778,
    description: 'App Store · iPhone 11 Pro Max',
  ),
  CoverPreset(
    label: 'iPhone 5.5"',
    width: 1242,
    height: 2208,
    description: 'App Store · iPhone 8 Plus',
  ),
  CoverPreset(
    label: 'iPad 12.9"',
    width: 2048,
    height: 2732,
    description: 'App Store · iPad Pro',
  ),
  CoverPreset(
    label: 'Play Store',
    width: 1024,
    height: 500,
    description: 'Play Store · Feature Graphic',
  ),
  CoverPreset(
    label: 'Android',
    width: 1080,
    height: 1920,
    description: 'Play Store · Screenshot',
  ),
];
