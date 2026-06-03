import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_decorations.dart';
import '../../core/constants/app_routes.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/entity_list_body.dart';
import '../../widgets/post_comments_sheet.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = ModalRoute.of(context)?.settings.arguments;
    if (id is! int) return;

    setState(() => _isLoading = true);
    try {
      final userId = AuthService().currentUser?.id;
      final post =
          await context.read<PostProvider>().fetchById(id, userId: userId);
      if (mounted) setState(() => _post = post);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLike() async {
    if (_post == null) return;
    final user = AuthService().currentUser;
    if (user == null) {
      showErrorSnackBar(context, 'Faça login para curtir posts.');
      return;
    }
    try {
      final updated =
          await context.read<PostProvider>().toggleLike(_post!, user.id);
      if (mounted) setState(() => _post = updated);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _handleComment() async {
    if (_post == null) return;
    final updated = await showPostCommentsSheet(context, post: _post!);
    if (updated != null && mounted) setState(() => _post = updated);
  }

  Future<void> _delete() async {
    if (_post == null) return;
    final confirmed = await confirmDelete(
      context,
      message: 'Deseja remover o post "${_post!.title}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<PostProvider>().delete(_post!.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Post removido.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Detalhes do post',
        actions: [
          if (_post != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await Navigator.pushNamed(
                  context,
                  AppRoutes.postForm,
                  arguments: _post!.id,
                );
                if (saved == true) _load();
              },
            ),
        ],
      ),
      body: DetailBody(
        isLoading: _isLoading,
        isEmpty: _post == null,
        emptyMessage: 'Post não encontrado.',
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_post!.imageUrl != null && _post!.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: AppDecorations.borderRadiusLg,
                        child: Image.network(
                          _post!.imageUrl!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 220,
                            color: AppColors.primaryLight,
                            child: const Icon(Icons.image_outlined, size: 48, color: AppColors.primary),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFFFF4757)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppDecorations.borderRadiusLg,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.article_outlined, size: 48, color: Colors.white),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _post!.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        DetailBadge(label: _post!.category, onDark: false),
                        DetailBadge(label: _post!.storeName, onDark: false),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _post!.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _InteractionButton(
                          icon: _post!.likedByMe
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: '${_post!.likes}',
                          color: _post!.likedByMe ? AppColors.like : null,
                          onPressed: _handleLike,
                        ),
                        const SizedBox(width: 12),
                        _InteractionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '${_post!.comments}',
                          onPressed: _handleComment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            StickyBottomActions(
              children: [
                CustomButton(
                  text: 'Excluir post',
                  variant: CustomButtonVariant.destructive,
                  icon: Icons.delete_outline,
                  onPressed: _delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onPressed;

  const _InteractionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onPressed,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
