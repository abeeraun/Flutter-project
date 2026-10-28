import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF8584B8);
  static const Color primaryDark = Color(0xFF6D6C9F);
  static const Color background = Color(0xFFEEF0F7);
  static const Color surface = Color(0xFFFAF9F4);
  static const Color textPrimary = Color(0xFF25242A);
  static const Color textSecondary = Color(0xFF777681);
  static const Color border = Color(0xFFD6D3CB);
  static const Color lavender = Color(0xFFD9D9EC);
  static const Color beige = Color(0xFFDED4C1);
  static const Color success = Color(0xFF7D9B8C);
  static const Color warning = Color(0xFFC4A777);
  static const Color danger = Color(0xFFB98282);
  static const Color low = Color(0xFF7D9B8C);
  static const Color medium = Color(0xFFC4A777);
  static const Color high = Color(0xFF9A88B2);
  static const Color blue = Color(0xFF8584B8);
  static const Color mint = Color(0xFF9BB9AD);
  static const Color lilac = Color(0xFFD9D9EC);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary);
    final text = GoogleFonts.tajawalTextTheme();
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: GoogleFonts.tajawal().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Color(0x1A4A4853),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      textTheme: text.copyWith(
        headlineSmall: const TextStyle(fontSize: 22, height: 1.25, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleLarge: const TextStyle(fontSize: 19, height: 1.35, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleMedium: const TextStyle(fontSize: 15, height: 1.35, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        bodyLarge: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.textPrimary),
        bodyMedium: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondary),
        labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.danger)),
        focusedErrorBorder: fieldBorder.copyWith(borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 1,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.lavender,
        height: 78,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }

  static Color priorityColor(String priority) {
    switch (priority) { case 'High': return AppColors.high; case 'Medium': return AppColors.medium; default: return AppColors.low; }
  }

  static Color statusColor(String status) {
    switch (status) { case 'Completed': return AppColors.success; case 'In Progress': return AppColors.primary; default: return AppColors.warning; }
  }
}
