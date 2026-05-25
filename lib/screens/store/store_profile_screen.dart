import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/post_model.dart';
import '../../models/store_model.dart';
import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_comments_sheet.dart';
import '../../widgets/store_card.dart';
import '../posts/owner_post_form_screen.dart';

/// Argumentos opcionais ao abrir [StoreProfileScreen].
class StoreProfileRouteArgs {
  final int? ownerUserId;
  final int? storeId;

  const StoreProfileRouteArgs({
    this.ownerUserId,
    this.storeId,
  });
}

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  final StoreService _storeService = StoreService();

  bool _isLoading = true;
  bool _loadingPosts = false;
  String? _errorMessage;
  StoreModel? _store;
  List<PostModel> _storePosts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadStore();
    });
  }

  StoreProfileRouteArgs? _readArgs() {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is StoreProfileRouteArgs) return raw;
    return null;
  }

  bool get _isOwnerOfThisStore {
    final user = AuthService().currentUser;
    if (user == null || _store == null) return false;
    return _store!.ownerUserId == user.id;
  }

  Future<void> _loadStore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final args = _readArgs();
    final auth = AuthService().currentUser;

    int? storeId = args?.storeId;
    int? ownerUserId = args?.ownerUserId;

    if (ownerUserId == null && auth != null && storeId == null) {
      ownerUserId = auth.id;
    }

    try {
      final store = await _storeService.resolveForProfile(
        storeId: storeId,
        ownerUserId: ownerUserId,
      );
      if (!mounted) return;
      setState(() => _store = store);
      if (store != null) {
        await _loadPosts(store.id);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Nao foi possivel carregar a loja.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPosts(int storeId) async {
    setState(() => _loadingPosts = true);
    try {
      final userId = AuthService().currentUser?.id;
      final posts = await context.read<PostProvider>().fetchByStoreId(
            storeId,
            userId: userId,
          );
      if (!mounted) return;
      setState(() => _storePosts = posts);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  void _syncPostFromProvider(PostModel updated) {
    setState(() {
      _storePosts = _storePosts
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
    });
  }

  Future<void> _handleLike(PostModel post) async {
    final user = AuthService().currentUser;
    if (user == null) {
      showErrorSnackBar(context, 'Faça login para curtir posts.');
      return;
    }
    try {
      final updated =
          await context.read<PostProvider>().toggleLike(post, user.id);
      _syncPostFromProvider(updated);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _handleComment(PostModel post) async {
    final updated = await showPostCommentsSheet(context, post: post);
    if (updated != null) _syncPostFromProvider(updated);
  }

  Future<void> _openNewPost() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const OwnerPostFormScreen()),
    );
    if (saved == true && _store != null && mounted) {
      await _loadPosts(_store!.id);
      if (!mounted) return;
      await context.read<PostProvider>().fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil da Loja')),
      floatingActionButton: _isOwnerOfThisStore
          ? FloatingActionButton.extended(
              onPressed: _openNewPost,
              icon: const Icon(Icons.add),
              label: const Text('Novo post'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadStore,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : _store == null
                  ? const Center(child: Text('Nenhuma loja encontrada.'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _loadStore();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StoreCard(
                              name: _store!.name,
                              category: _store!.category,
                              address: _store!.address ??
                                  'Endereco nao informado',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _store!.description?.isNotEmpty == true
                                  ? _store!.description!
                                  : 'Sem descricao.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Horario: ${_store!.openingHours ?? "Nao informado"}',
                            ),
                            Text(
                              'Contato: ${_store!.contact ?? "Nao informado"}',
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Publicações',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            if (_loadingPosts)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_storePosts.isEmpty)
                              const Text(
                                'Esta loja ainda não tem posts.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _storePosts.length,
                                itemBuilder: (context, index) {
                                  final post = _storePosts[index];
                                  return PostCard(
                                    post: post,
                                    onLike: () => _handleLike(post),
                                    onComment: () => _handleComment(post),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
