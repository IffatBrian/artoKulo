import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Token warna dari DESIGN.md (artoKulo)
class AppColors {
  static const primary = Color(0xFF1D72B8); // Serene Blue
  static const secondary = Color(0xFFD0E7F9); // Ice Glaze
  static const tertiary = Color(0xFF4F46E5); // Soft Indigo
  static const text = Color(0xFF1E293B); // Deep Slate
  static const background = Color(0xFFF8FAFD);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const borderSoft = Color(0xFFEAF2F9);
  static const hint = Color(0xFF64748B);
  static const chipInactive = Color(0xFFF1F5F9);
  static const income = Color(0xFF10B981);
  static const pending = Color(0xFFF59E0B);
  static const expense = Color(0xFFEF4444);
}

const heroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1D72B8), Color(0xFF2563EB)],
);

/// Level 1 elevation: kartu putih + bayangan ambient bernuansa langit.
BoxDecoration cardDecoration({double radius = 24}) => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xCCE2E8F0)),
      boxShadow: const [
        BoxShadow(
            color: Color(0x0F1D72B8),
            blurRadius: 20,
            spreadRadius: -2,
            offset: Offset(0, 4)),
        BoxShadow(
            color: Color(0x0A1E293B),
            blurRadius: 6,
            spreadRadius: -1,
            offset: Offset(0, 2)),
      ],
    );

const tnum = [FontFeature.tabularFigures()];

/// Format nilai uang ke rupiah.
String rupiah(num v) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(v);

/// Membuat tema visual aplikasi.
ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: const Color(0xFFBA1A1A),
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.text,
      titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
      enabledBorder: border(AppColors.border),
      border: border(AppColors.border),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(AppColors.expense),
      focusedErrorBorder: border(AppColors.expense, 1.5),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF263143),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

/// Warna transparan yang pasti dirender dengan alpha (menggantikan withOpacity).
extension SoftColor on Color {
  // ignore: deprecated_member_use
  Color soft(double o) => Color.fromRGBO(red, green, blue, o);
}
