import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;

  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  static BoxDecoration card({
    Color? color,
    bool elevated = true,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadiusLg,
        boxShadow: elevated ? const [AppColors.cardShadow] : null,
        border: elevated ? null : Border.all(color: AppColors.border),
      );

  static BoxDecoration searchBar = BoxDecoration(
    color: AppColors.surfaceAlt,
    borderRadius: borderRadiusXl,
    border: Border.all(color: AppColors.borderLight),
  );

  static BoxDecoration chipSelected = BoxDecoration(
    color: AppColors.primary,
    borderRadius: borderRadiusFull,
    boxShadow: const [
      BoxShadow(
        color: Color(0x33EA1D2C),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration chipUnselected = BoxDecoration(
    color: AppColors.surface,
    borderRadius: borderRadiusFull,
    border: Border.all(color: AppColors.border),
  );
}
