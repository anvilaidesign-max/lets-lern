import 'package:flutter/material.dart';

/// Design tokens (ARCHITECTURE.md 11.1).
class AppColors {
  AppColors._();

  static const lightBackground = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF000000);
  static const lightSecondary = Color(0xFF555555);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightBorder = Color(0xFFE6E6E6);

  static const darkBackground = Color(0xFF0E0E0E);
  static const darkText = Color(0xFFF2F2F2);
  static const darkSecondary = Color(0xFFA0A0A0);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkBorder = Color(0xFF2A2A2A);

  static const success = Color(0xFF15803D);
  static const successDark = Color(0xFF4ADE80);
  static const error = Color(0xFFB91C1C);
  static const errorDark = Color(0xFFF87171);
  static const streak = Color(0xFFEA580C);

  /// One accent colour per topic, used for chips and small icons only.
  static const topic = <String, Color>{
    'math': Color(0xFF2563EB),
    'english': Color(0xFFDC2626),
    'french': Color(0xFF7C3AED),
    'science': Color(0xFF059669),
    'politics': Color(0xFF475569),
    'economics': Color(0xFFD97706),
    'finance': Color(0xFF0D9488),
    'relations': Color(0xFFDB2777),
  };

  static Color forTopic(String code) => topic[code] ?? const Color(0xFF555555);

  /// Topic colours are tuned for white. On dark backgrounds they are lifted so
  /// small text and icons keep enough contrast.
  static Color forTopicOn(Brightness brightness, String code) {
    final base = forTopic(code);
    if (brightness == Brightness.light) return base;
    return Color.lerp(base, Colors.white, 0.35)!;
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double chip = 999;
  static const double button = 14;
}

class AppDurations {
  AppDurations._();

  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 300);
}

class AppTextSizes {
  AppTextSizes._();

  static const double body = 16;
  static const double card = 20;
  static const double heading = 24;
  static const double display = 28;
}
