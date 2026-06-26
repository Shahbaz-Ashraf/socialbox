import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryLight = Color(0xFF4F46E5); // Indigo
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF2DD4BF);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF7F7FA);

  static const List<Color> brandGradient = [
    Color(0xFF4F46E5),
    Color(0xFF14B8A6),
  ];
}
