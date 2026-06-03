import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/ui_helpers.dart';
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
      appBar: AppBar(
        title: const Text('Detalhes do post'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Post não encontrado.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(_post!.title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text('Loja: ${_post!.storeName}'),
                      Text('Categoria: ${_post!.category}'),
                      const SizedBox(height: 12),
                      Text(_post!.description),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _handleLike,
                            icon: Icon(
                              _post!.likedByMe
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _post!.likedByMe ? Colors.red : null,
                            ),
                          ),
                          Text('${_post!.likes}'),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _handleComment,
                            icon: const Icon(Icons.chat_bubble_outline),
                          ),
                          Text('${_post!.comments}'),
                        ],
                      ),
                      if (_post!.imageUrl != null &&
                          _post!.imageUrl!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Imagem: ${_post!.imageUrl}'),
                      ],
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir post'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
