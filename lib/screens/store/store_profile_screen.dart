import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/post_model.dart';
import '../../models/store_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../core/constants/app_routes.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_comments_sheet.dart';
import '../../widgets/store_card.dart';
import '../posts/owner_post_form_screen.dart';

/// Argumentos opcionais ao abrir [StoreProfileScreen].
class StoreProfileRouteArgs {
  final int? ownerUserId;
  final int? storeId;

  const StoreProfileRouteArgs({this.ownerUserId, this.storeId});
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
  List<StoreModel> _ownerStores = [];
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

    // Sem uma loja específica, esta é sempre a área "Minha loja" do
    // usuário autenticado. Não confie em um ownerUserId recebido pela rota.
    if (auth != null && storeId == null) {
      ownerUserId = auth.id;
    }

    try {
      StoreModel? store;
      if (ownerUserId != null && storeId == null) {
        final stores = (await _storeService.getByOwner(
          ownerUserId,
        )).where((store) => store.ownerUserId == auth?.id).toList();
        _ownerStores = stores;
        store = stores.isEmpty ? null : stores.first;
      } else {
        store = await _storeService.resolveForProfile(
          storeId: storeId,
          ownerUserId: ownerUserId,
        );
      }
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
      final updated = await context.read<PostProvider>().toggleLike(
        post,
        user.id,
      );
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
      MaterialPageRoute(
        builder: (_) => OwnerPostFormScreen(storeId: _store?.id),
      ),
    );
    if (saved == true && _store != null && mounted) {
      await _loadPosts(_store!.id);
      if (!mounted) return;
      await context.read<PostProvider>().fetchAll();
    }
  }

  Future<void> _selectStore(int? id) async {
    if (id == null || id == _store?.id) return;
    final store = _ownerStores.firstWhere((item) => item.id == id);
    setState(() => _store = store);
    await _loadPosts(store.id);
  }

  Future<void> _editStore() async {
    if (_store == null) return;
    final saved = await Navigator.pushNamed(
      context,
      AppRoutes.storeForm,
      arguments: _store!.id,
    );
    if (saved == true && mounted) await _loadStore();
  }

  Future<void> _toggleStoreStatus() async {
    if (_store == null) return;
    try {
      await context.read<StoreProvider>().update(_store!.id, {
        'isActive': !_store!.isActive,
      });
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        _store!.isActive ? 'Loja desativada.' : 'Loja reativada.',
      );
      await _loadStore();
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _editPost(PostModel post) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OwnerPostFormScreen(storeId: post.storeId, postId: post.id),
      ),
    );
    if (saved == true && mounted && _store != null) {
      await _loadPosts(_store!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Perfil da Loja'),
      floatingActionButton: _isOwnerOfThisStore
          ? FloatingActionButton.extended(
              onPressed: _openNewPost,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo post'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? EmptyState(
              icon: Icons.storefront_outlined,
              title: 'Erro ao carregar',
              subtitle: _errorMessage,
              actionLabel: 'Tentar novamente',
              onAction: _loadStore,
            )
          : _store == null
          ? const EmptyState(
              icon: Icons.store_outlined,
              title: 'Nenhuma loja encontrada',
            )
          : RefreshIndicator(
              onRefresh: _loadStore,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_ownerStores.length > 1) ...[
                      DropdownButtonFormField<int>(
                        value: _store!.id,
                        decoration: const InputDecoration(
                          labelText: 'Selecione a loja',
                        ),
                        items: _ownerStores
                            .map(
                              (store) => DropdownMenuItem(
                                value: store.id,
                                child: Text(store.name),
                              ),
                            )
                            .toList(),
                        onChanged: _selectStore,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_isOwnerOfThisStore) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _editStore,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar loja'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _toggleStoreStatus,
                              icon: Icon(
                                _store!.isActive
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              label: Text(
                                _store!.isActive ? 'Desativar' : 'Reativar',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    StoreCard(
                      name: _store!.name,
                      category: _store!.category,
                      address: _store!.address ?? 'Endereco nao informado',
                      imageUrl: _store!.profileImageUrl,
                      hero: true,
                    ),
                    if (!_store!.isActive)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Chip(label: Text('Loja desativada')),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sobre',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _store!.description?.isNotEmpty == true
                                ? _store!.description!
                                : 'Sem descricao.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          DetailInfoRow(
                            icon: Icons.schedule_rounded,
                            label: 'Horário',
                            value: _store!.openingHours ?? 'Nao informado',
                          ),
                          DetailInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Contato',
                            value: _store!.contact ?? 'Nao informado',
                          ),
                          DetailInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Endereço',
                            value: _store!.address ?? 'Nao informado',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'Publicações',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (_storePosts.isNotEmpty)
                          Text(
                            '${_storePosts.length} posts',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
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
                      const EmptyState(
                        icon: Icons.article_outlined,
                        title: 'Nenhum post ainda',
                        subtitle: 'Esta loja ainda não publicou conteúdo.',
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
                            onEdit: _isOwnerOfThisStore
                                ? () => _editPost(post)
                                : null,
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
