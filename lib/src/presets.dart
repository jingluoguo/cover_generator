import 'models/cover_preset.dart';

/// Built-in size presets for common app store promotional images.
const List<CoverPreset> kCoverPresets = [
  CoverPreset(
    label: 'iPhone 6.5"',
    width: 1242,
    height: 2688,
    description: 'App Store · iPhone 11 Pro Max',
  ),
  CoverPreset(
    label: 'iPad 13"',
    width: 2064,
    height: 2752,
    description: 'App Store · iPad Pro 13"',
  ),
  CoverPreset(
    label: '华为',
    width: 450,
    height: 800,
    description: 'Android · Huawei',
  ),
];
