import 'package:flutter/material.dart';

/// SevakConnect Strict Elevation & Shadow Tokens (DESIGN.md)
abstract class AppShadows {
  /// Level 1: Standard cards (12% opacity navy-tinted shadow)
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x1F26365C), // 12% opacity Vitthal Navy
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 2: Reserved ONLY for critical overlays/bottom sheets during emergencies (20% opacity)
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x3326365C), // 20% opacity Vitthal Navy
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
}
