import 'package:flutter/material.dart';

import 'tokens.dart';

/// Clean, white, minimal themes (ARCHITECTURE.md 11.1). Colour comes from
/// topic accents; everything else is black, white and greys.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        text: AppColors.lightText,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightSurface,
        border: AppColors.lightBorder,
        error: AppColors.error,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        text: AppColors.darkText,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        border: AppColors.darkBorder,
        error: AppColors.errorDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color text,
    required Color secondary,
    required Color surface,
    required Color border,
    required Color error,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: text,
      onPrimary: background,
      primaryContainer: surface,
      onPrimaryContainer: text,
      secondary: secondary,
      onSecondary: background,
      // Selected tab indicator and chips: a soft grey pill with the ink colour
      // on top (without these Flutter derives white-on-grey, which is invisible).
      secondaryContainer: surface,
      onSecondaryContainer: text,
      tertiary: secondary,
      onTertiary: background,
      error: error,
      onError: background,
      surface: background,
      onSurface: text,
      onSurfaceVariant: secondary,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: surface,
      outline: border,
      outlineVariant: border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = base.textTheme
        .copyWith(
          displaySmall: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.15),
          headlineMedium: const TextStyle(fontSize: AppTextSizes.display, fontWeight: FontWeight.w700, height: 1.2),
          headlineSmall: const TextStyle(fontSize: AppTextSizes.heading, fontWeight: FontWeight.w700, height: 1.25),
          titleLarge: const TextStyle(fontSize: AppTextSizes.card, fontWeight: FontWeight.w600, height: 1.3),
          titleMedium: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
          bodyLarge: const TextStyle(fontSize: AppTextSizes.body, height: 1.5),
          bodyMedium: const TextStyle(fontSize: 15, height: 1.45),
          bodySmall: const TextStyle(fontSize: 13, height: 1.4),
          labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: text, displayColor: text);

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button));

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: background,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: text,
          foregroundColor: background,
          minimumSize: const Size(64, 52),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(64, 52),
          shape: buttonShape,
          side: BorderSide(color: border, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: text, textStyle: textTheme.labelLarge),
      ),
      chipTheme: ChipThemeData(
        // Selected chips are solid ink with inverted text, like the buttons.
        color: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? text : background,
        ),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip)),
        labelStyle: textTheme.bodyMedium!.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected) ? background : text,
          ),
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: surface,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? text : secondary),
        ),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(textTheme.bodySmall),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: text,
        contentTextStyle: TextStyle(color: background, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: text,
        linearTrackColor: border,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? background : secondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? text : surface,
        ),
        trackOutlineColor: WidgetStatePropertyAll(border),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: text,
          selectedForegroundColor: background,
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}
