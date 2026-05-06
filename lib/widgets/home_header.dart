import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.storefront_outlined,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              'LocalHub',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
      ),
    );
  }
}