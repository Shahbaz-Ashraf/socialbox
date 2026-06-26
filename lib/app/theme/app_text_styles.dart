import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
  );

  static TextStyle sectionHeader(BuildContext context) => TextStyle(
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      );

  static TextStyle stepLabel(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle onGradient(BuildContext context) => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      );

  static TextStyle heroGreeting(BuildContext context) => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
        letterSpacing: 0.1,
      );

  static TextStyle heroTitle(BuildContext context) => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.6,
        height: 1.1,
      );

  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.2,
      );
}