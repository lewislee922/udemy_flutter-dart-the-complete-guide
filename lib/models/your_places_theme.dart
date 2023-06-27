import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YourPlacesTheme {
  static final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 102, 6, 247),
      background: const Color.fromARGB(255, 56, 49, 56));

  static final theme = ThemeData().copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.background,
    textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
      titleSmall: GoogleFonts.ubuntuCondensed(
          fontWeight: FontWeight.bold, fontSize: 12),
      titleMedium: GoogleFonts.ubuntuCondensed(
          fontWeight: FontWeight.bold, fontSize: 20),
      titleLarge: GoogleFonts.ubuntuCondensed(
          fontWeight: FontWeight.bold, fontSize: 24),
    ),
  );
}
