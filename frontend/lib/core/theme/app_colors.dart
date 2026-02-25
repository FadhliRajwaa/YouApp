import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF09141A);
  static const Color cardDark = Color(0xFF0D1D23);
  static const Color inputBg = Color.fromRGBO(255, 255, 255, 0.06);
  static const Color white = Colors.white;
  static const Color white40 = Color.fromRGBO(255, 255, 255, 0.4);
  static const Color white30 = Color.fromRGBO(255, 255, 255, 0.3);
  static const Color grey500 = Color(0xFFA0AEC0);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF1F4247),
      Color(0xFF0D1D23),
      Color(0xFF09141A),
    ],
    stops: [0.0, 0.56, 1.0],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF62CDCB),
      Color(0xFF4599DB),
    ],
  );

  static const LinearGradient goldenGradient = LinearGradient(
    colors: [
      Color(0xFF94783E),
      Color(0xFFF3EDA6),
      Color(0xFFF8FAE5),
      Color(0xFFFFE2BE),
      Color(0xFFD5BE88),
      Color(0xFFF8FAE5),
      Color(0xFFD5BE88),
    ],
    stops: [0.0, 0.13, 0.29, 0.51, 0.84, 0.96, 1.0],
  );

  static const LinearGradient profileCardGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF162329),
      Color(0xFF1A2E35),
    ],
  );
}
