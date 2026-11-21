import 'package:material_ui/material_ui.dart';

/// Palette inspired by Madinah: green domes, desert sand and soft gold.
class AppColors {
  static const green = Color(0xFF1F7A55);
  static const greenDark = Color(0xFF145239);
  static const sand = Color(0xFFFBF5E9);
  static const sandDeep = Color(0xFFF1E4C8);
  static const gold = Color(0xFFC9A44C);
  static const ink = Color(0xFF2B2A28);
  static const muted = Color(0xFF6E6A62);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.green,
    primary: AppColors.green,
    secondary: AppColors.gold,
    surface: AppColors.sand,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'HindSiliguri',
    scaffoldBackgroundColor: AppColors.sand,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sand,
      foregroundColor: AppColors.greenDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'HindSiliguri',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.greenDark,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(
            fontFamily: 'HindSiliguri',
            fontSize: 18,
            fontWeight: FontWeight.w600),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.sandDeep),
      ),
    ),
  );
}

const arabicStyle = TextStyle(
  fontFamily: 'Amiri',
  fontSize: 26,
  height: 2.0,
  color: AppColors.greenDark,
);
