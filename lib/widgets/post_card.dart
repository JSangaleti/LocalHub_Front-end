import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_decorations.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onSave;
  final bool isSaved;
  final bool compact;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.onEdit,
    this.onSave,
    this.isSaved = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = compact ? 120.0 : 160.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.card(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PostImage(
                imageUrl: post.imageUrl,
                category: post.category,
                isPromotion: post.isPromotion,
                height: imageHeight,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StoreAvatar(
                          name: post.storeName,
                          imageUrl: post.storeImageUrl,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.storeName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onEdit != null)
                          IconButton(
                            tooltip: 'Editar post',
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        post.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ActionChip(
                          icon: post.likedByMe
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: '${post.likes}',
                          color: post.likedByMe ? AppColors.like : null,
                          onPressed: onLike,
                        ),
                        const SizedBox(width: 8),
                        _ActionChip(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '${post.comments}',
                          onPressed: onComment,
                        ),
                        const Spacer(),
                        _ActionChip(
                          icon: isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          label: '',
                          color: isSaved ? AppColors.primary : null,
                          onPressed: onSave,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final bool isPromotion;
  final double height;

  const _PostImage({
    required this.imageUrl,
    required this.category,
    required this.isPromotion,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: height,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _Placeholder(height: height),
                )
              : _Placeholder(height: height),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: AppDecorations.borderRadiusFull,
            ),
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ),
        if (isPromotion)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: AppDecorations.borderRadiusFull,
              ),
              child: Text(
                'Promo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double height;

  const _Placeholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, Color(0xFFFFF0EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.primary, size: 32),
      ),
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _StoreAvatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final fallback = Text(
      initial,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );

    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.primaryLight,
      foregroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      onForegroundImageError: imageUrl != null && imageUrl!.isNotEmpty
          ? (exception, stackTrace) {}
          : null,
      child: fallback,
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onPressed;

  const _ActionChip({
    required this.icon,
    required this.label,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: AppDecorations.borderRadiusFull,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppDecorations.borderRadiusFull,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
