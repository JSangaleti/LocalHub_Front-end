import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/post_model.dart';
import '../../models/store_model.dart';
import '../../providers/post_provider.dart';
import '../../services/auth_service.dart';
import '../../services/favorite_store_service.dart';
import '../../services/my_store_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/category_filter_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/home_header.dart';
import '../../widgets/masonry_post_grid.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_comments_sheet.dart';
import '../../widgets/skeleton_loaders.dart';
import '../posts/owner_post_form_screen.dart';
import '../store/store_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MyStoreService _myStoreService = MyStoreService();
  final FavoriteStoreService _favoriteStoreService = FavoriteStoreService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedCategory = 'Todos';
  List<String> categories = ['Todos', 'Favoritos'];
  Set<int> _favoriteStoreIds = {};
  StoreModel? _myStore;
  String _searchQuery = '';

  bool get _ownsStore => _myStore != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyStore();
      _loadPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMyStore() async {
    try {
      final store = await _myStoreService.findStoreForCurrentUser();
      if (!mounted) return;
      setState(() => _myStore = store);
    } catch (_) {
      if (mounted) setState(() => _myStore = null);
    }
  }

  Future<void> _loadPosts({String? search}) async {
    try {
      final userId = AuthService().currentUser?.id;
      await context.read<PostProvider>().fetchAll(userId: userId, search: search);
      if (userId != null) {
        try {
          final favorites = await _favoriteStoreService.getAll(userId);
          _favoriteStoreIds = favorites.map((store) => store.id).toSet();
        } catch (_) {
          _favoriteStoreIds = {};
        }
      }
      if (!mounted) return;
      final posts = context.read<PostProvider>().items;
      final mappedCategories = <String>{
        'Todos',
        'Favoritos',
        ...posts.map((post) => post.category),
      }.toList();
      setState(() {
        categories = mappedCategories;
        if (!categories.contains(selectedCategory)) selectedCategory = 'Todos';
      });
    } catch (_) {
      // Erro tratado via provider
    }
  }

  Future<void> _handleLike(PostModel post) async {
    final user = AuthService().currentUser;
    if (user == null) {
      showErrorSnackBar(context, 'Faça login para curtir posts.');
      return;
    }
    try {
      await context.read<PostProvider>().toggleLike(post, user.id);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> _handleComment(PostModel post) async {
    await showPostCommentsSheet(context, post: post);
  }

  Future<void> _openNewPost() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const OwnerPostFormScreen()),
    );
    if (saved == true && mounted) await _loadPosts(search: _searchQuery);
  }

  Future<void> _openStoreProfile(PostModel post) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.storeProfile,
      arguments: StoreProfileRouteArgs(storeId: post.storeId),
    );
    if (mounted) await _loadPosts(search: _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final filteredPosts = selectedCategory == 'Todos'
        ? provider.items
        : selectedCategory == 'Favoritos'
        ? provider.items
              .where((post) => _favoriteStoreIds.contains(post.storeId))
              .toList()
        : provider.items
              .where((post) => post.category == selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _ownsStore
          ? FloatingActionButton.extended(
              onPressed: _openNewPost,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo post'),
            )
          : null,
      body: Column(
        children: [
          HomeHeader(hasStore: _ownsStore, onStoreChanged: _loadMyStore),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Buscar posts, lojas...',
              showClear: _searchQuery.isNotEmpty,
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
                _loadPosts(search: '');
              },
              onChanged: (value) => setState(() => _searchQuery = value),
              onSubmitted: (_) => _loadPosts(search: _searchQuery),
            ),
          ),
          CategoryFilterBar(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: (category) {
              setState(() => selectedCategory = category);
              _loadPosts(search: _searchQuery);
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.items.isEmpty) {
                  return const FeedSkeleton();
                }

                if (provider.error != null && provider.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Algo deu errado',
                    subtitle: provider.error,
                    actionLabel: 'Tentar novamente',
                    onAction: () => _loadPosts(search: _searchQuery),
                  );
                }

                if (filteredPosts.isEmpty) {
                  return EmptyState(
                    icon: selectedCategory == 'Favoritos'
                        ? Icons.favorite_border_rounded
                        : Icons.explore_outlined,
                    title: selectedCategory == 'Favoritos'
                        ? 'Nenhuma loja favoritada'
                        : 'Nenhum post encontrado',
                    subtitle: selectedCategory == 'Favoritos'
                        ? 'Favorite uma loja no perfil dela para vê-la aqui.'
                        : 'Tente outra categoria ou termo de busca.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _loadPosts(search: _searchQuery);
                    await _loadMyStore();
                  },
                  color: AppColors.primary,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: isWide
                                ? MasonryPostGrid(
                                    posts: filteredPosts,
                                    onTap: _openStoreProfile,
                                    onLike: _handleLike,
                                    onComment: _handleComment,
                                  )
                                : Column(
                                    children: filteredPosts
                                        .map(
                                          (post) => PostCard(
                                            post: post,
                                            onTap: () => _openStoreProfile(post),
                                            onLike: () => _handleLike(post),
                                            onComment: () => _handleComment(post),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
