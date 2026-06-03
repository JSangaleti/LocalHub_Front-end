import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'empty_state.dart';
import 'skeleton_loaders.dart';

class EntityListBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback onRetry;
  final Widget child;

  const EntityListBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    required this.onRetry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && isEmpty) {
      return const ListSkeleton();
    }

    if (error != null && isEmpty) {
      return ErrorState(message: error!, onRetry: onRetry);
    }

    if (isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyMessage,
        subtitle: 'Comece adicionando um novo item.',
        actionLabel: 'Atualizar',
        onAction: onRetry,
      );
    }

    return child;
  }
}

class DetailBody extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final String emptyMessage;
  final Widget child;

  const DetailBody({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: emptyMessage,
      );
    }

    return child;
  }
}
