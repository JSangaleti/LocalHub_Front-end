import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/admin_entity_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/entity_list_body.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final userId = AuthService().currentUser?.id;
      await context.read<PostProvider>().fetchAll(userId: userId);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _openForm({int? id}) async {
    final saved = await Navigator.pushNamed(
      context,
      AppRoutes.postForm,
      arguments: id,
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Posts'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          return EntityListBody(
            isLoading: provider.isLoading,
            error: provider.error,
            isEmpty: provider.items.isEmpty,
            emptyMessage: 'Nenhum post cadastrado.',
            emptyIcon: Icons.article_outlined,
            onRetry: _load,
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final post = provider.items[index];
                  return AdminEntityCard(
                    title: post.title,
                    subtitle: '${post.storeName} • ${post.category}',
                    icon: Icons.article_outlined,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.postDetail,
                      arguments: post.id,
                    ),
                    onEdit: () => _openForm(id: post.id),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
