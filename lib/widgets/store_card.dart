import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_decorations.dart';

class StoreCard extends StatelessWidget {
  final String name;
  final String category;
  final String address;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool hero;

  const StoreCard({
    super.key,
    required this.name,
    required this.category,
    required this.address,
    this.imageUrl,
    this.onTap,
    this.hero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hero) {
      return _HeroStoreCard(
        name: name,
        category: category,
        address: address,
        imageUrl: imageUrl,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDecorations.borderRadiusLg,
        child: Ink(
          decoration: AppDecorations.card(),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StoreImage(name: name, imageUrl: imageUrl, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppDecorations.borderRadiusFull,
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStoreCard extends StatelessWidget {
  final String name;
  final String category;
  final String address;
  final String? imageUrl;

  const _HeroStoreCard({
    required this.name,
    required this.category,
    required this.address,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppDecorations.borderRadiusLg,
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF4757)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33EA1D2C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.35),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreImage(name: name, imageUrl: imageUrl, size: 64, onDark: true),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                  child: Text(
                    category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.white.withValues(alpha: 0.85)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreImage extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final bool onDark;

  const _StoreImage({
    required this.name,
    this.imageUrl,
    required this.size,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppDecorations.borderRadiusMd,
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _AvatarFallback(initial: initial, size: size, onDark: onDark),
        ),
      );
    }

    return _AvatarFallback(initial: initial, size: size, onDark: onDark);
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initial;
  final double size;
  final bool onDark;

  const _AvatarFallback({
    required this.initial,
    required this.size,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.2) : AppColors.primaryLight,
        borderRadius: AppDecorations.borderRadiusMd,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: onDark ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}
