import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IrworobongdoColors {
  IrworobongdoColors._();

  // Fondos nocturnos cálidos
  static const Color nightSky = Color(0xFF0E131F);       // Cielo noche (fondo principal)
  static const Color deepIndigo = Color(0xFF172033);     // Índigo (tarjetas y superficies)
  static const Color elevatedIndigo = Color(0xFF1F2B44); // Superficie elevada / inputs

  // Acentos tradicionales
  static const Color vermilion = Color(0xFFD94E34);      // Bermellón (sol / acción principal)
  static const Color jade = Color(0xFF3E8E7E);           // Jade (montañas / estados positivos)
  static const Color plum = Color(0xFF8C4A6B);           // Ciruela (acentos secundarios / parejas)
  static const Color warmGold = Color(0xFFD9A05B);       // Oro suave (estrellas / calificación)

  // Textos y bordes
  static const Color ivory = Color(0xFFF4EFE6);          // Marfil (texto principal)
  static const Color mutedIvory = Color(0xFFB8B0A2);     // Marfil tenue (subtítulos)
  static const Color borderSubtle = Color(0xFF2B3956);   // Borde sutil índigo
}

class IrworobongdoTheme {
  IrworobongdoTheme._();

  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      headlineMedium: GoogleFonts.notoSansKr(
        color: IrworobongdoColors.ivory,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.notoSansKr(
        color: IrworobongdoColors.ivory,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.notoSansKr(
        color: IrworobongdoColors.ivory,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.notoSansKr(
        color: IrworobongdoColors.ivory,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        color: IrworobongdoColors.mutedIvory,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.notoSansKr(
        color: IrworobongdoColors.ivory,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: IrworobongdoColors.nightSky,
      colorScheme: const ColorScheme.dark(
        primary: IrworobongdoColors.vermilion,
        onPrimary: IrworobongdoColors.ivory,
        secondary: IrworobongdoColors.jade,
        onSecondary: IrworobongdoColors.ivory,
        tertiary: IrworobongdoColors.plum,
        surface: IrworobongdoColors.deepIndigo,
        onSurface: IrworobongdoColors.ivory,
        outline: IrworobongdoColors.borderSubtle,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: IrworobongdoColors.nightSky,
        foregroundColor: IrworobongdoColors.ivory,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: IrworobongdoColors.deepIndigo,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: IrworobongdoColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: IrworobongdoColors.elevatedIndigo,
        hintStyle: const TextStyle(color: IrworobongdoColors.mutedIvory),
        labelStyle: const TextStyle(color: IrworobongdoColors.mutedIvory),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IrworobongdoColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: IrworobongdoColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: IrworobongdoColors.vermilion,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: IrworobongdoColors.vermilion,
          foregroundColor: IrworobongdoColors.ivory,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: IrworobongdoColors.elevatedIndigo,
        selectedColor: IrworobongdoColors.jade.withValues(alpha: 0.25),
        labelStyle: const TextStyle(color: IrworobongdoColors.ivory),
        side: const BorderSide(color: IrworobongdoColors.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}