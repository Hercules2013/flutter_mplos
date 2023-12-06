import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static const String fontFamily = 'DM Sans';

  // Text style for body
  static TextStyle bodyLg = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle body = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySm = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  static TextStyle bodyXs = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w300,
  );

  /// Text style for heading

  static TextStyle h1 = GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h2 = GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h3 = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h4 = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
}
