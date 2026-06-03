import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — LocalHub palette
  static const primary = Color(0xFF22577A);
  static const primaryDark = Color(0xFF1B4565);
  static const primaryLight = Color(0xFF8EB7C4);
  static const secondary = Color(0xFF38A3A5);
  static const tertiary = Color(0xFF57CC99);
  static const accent = Color(0xFFFF8A3D);

  // UI base
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFD7E1EF);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF0F4F8);

  // Text
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onAccent = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);

  // Semantic
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF39C12);
  static const error = Color(0xFFE74C3C);
  static const like = Color(0xFF22577A);

  // Shadows
  static const shadowColor = Color(0x1A0F172A);
  static const cardShadow = BoxShadow(
    color: Color(0x0F0F172A),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  static const cardShadowHover = BoxShadow(
    color: Color(0x1A0F172A),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}