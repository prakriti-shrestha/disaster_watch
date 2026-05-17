import 'package:flutter/material.dart';

/// Emergency Operations Center Design System
class EOC {
  // === PALETTE ===

  // Base
  static const Color graphite = Color(0xFF0A0E12); // Main background
  static const Color charcoal = Color(0xFF12161C); // Panels
  static const Color steel = Color(0xFF1A2028); // Cards
  static const Color border = Color(0xFF252D38); // Subtle borders
  static const Color borderActive = Color(0xFF3A4555); // Active borders

  // Text
  static const Color textPrimary = Color(0xFFE8EDF2);
  static const Color textSecondary = Color(0xFF9AA7B5);
  static const Color textMuted = Color(0xFF5C6878);

  // Status colors
  static const Color amber = Color(0xFFFFB020); // Active alerts
  static const Color amberGlow = Color(0x33FFB020);
  static const Color critical = Color(0xFFFF3344); // Critical only
  static const Color criticalGlow = Color(0x33FF3344);
  static const Color cyan = Color(0xFF00E5FF); // Info/safe
  static const Color cyanGlow = Color(0x3300E5FF);
  static const Color terrainGreen = Color(0xFF4ADE80); // Operational
  static const Color hazardYellow = Color(0xFFFBBF24);

  // === SEVERITY MAPPING ===

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return critical;
      case 'high':
        return amber;
      case 'medium':
        return hazardYellow;
      case 'low':
        return terrainGreen;
      default:
        return cyan;
    }
  }

  static Color severityGlow(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return criticalGlow;
      case 'high':
        return amberGlow;
      case 'medium':
        return const Color(0x33FBBF24);
      case 'low':
        return const Color(0x334ADE80);
      default:
        return cyanGlow;
    }
  }

  // === TYPOGRAPHY ===

  static const String monoFont = 'JetBrainsMono';

  static TextStyle headerLarge = const TextStyle(
    fontFamily: monoFont,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 2,
  );

  static TextStyle headerMedium = const TextStyle(
    fontFamily: monoFont,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 1.5,
  );

  static TextStyle label = const TextStyle(
    fontFamily: monoFont,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: textSecondary,
    letterSpacing: 1.8,
  );

  static TextStyle body = const TextStyle(
    fontFamily: monoFont,
    fontSize: 13,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle mono = const TextStyle(
    fontFamily: monoFont,
    fontSize: 11,
    color: textSecondary,
  );

  static TextStyle code = const TextStyle(
    fontFamily: monoFont,
    fontSize: 12,
    color: cyan,
  );

  // === COMPONENTS ===

  static BoxDecoration panel({Color? accent}) {
    return BoxDecoration(
      color: charcoal,
      border: Border.all(
        color: accent ?? border,
        width: 1,
      ),
    );
  }

  static BoxDecoration glowPanel(Color glowColor) {
    return BoxDecoration(
      color: charcoal,
      border: Border.all(color: glowColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
