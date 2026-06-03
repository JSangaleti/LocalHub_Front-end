import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/post_model.dart';
import '../../models/store_model.dart';
import '../../providers/post_provider.dart';
import '../../services/auth_service.dart';
import '../../services/my_store_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/category_filter_bar.dart';
import '../../widgets/home_header.dart';
import '../../widgets/post_card.dart';
import '../../widgets/post_comments_sheet.dart';
import '../posts/owner_post_form_screen.dart';
import '../store/store_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MyStoreService _myStoreService = MyStoreService();
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'Todos';
  List<String> categories = ['Todos'];
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
      if (!mounted) return;
      final posts = context.read<PostProvider>().items;
      final mappedCategories = <String>{
        'Todos',
        ...posts.map((post) => post.category),
      }.toList();
      setState(() {
        categories = mappedCategories;
        if (!categories.contains(selectedCategory)) selectedCategory = 'Todos';
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostProvider>();
    final filteredPosts = selectedCategory == 'Todos'
        ? provider.items
        : provider.items.where((post) => post.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _ownsStore
          ? FloatingActionButton.extended(
              onPressed: _openNewPost,
              icon: const Icon(Icons.add),
              label: const Text('Novo post'),
            )
          : null,
      body: Column(
        children: [
          HomeHeader(hasStore: _ownsStore, onStoreChanged: _loadMyStore),

          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar posts',
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadPosts(search: '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _searchQuery = value),
              onSubmitted: (_) => _loadPosts(search: _searchQuery),
            ),
          ),

          // Filtro de categorias
          CategoryFilterBar(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: (category) {
              setState(() => selectedCategory = category);
              _loadPosts(search: _searchQuery);
            },
          ),

          // Feed
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading && provider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(provider.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _loadPosts(search: _searchQuery),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text('Nenhum post para exibir.'));
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await _loadPosts(search: _searchQuery);
                      await _loadMyStore();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return PostCard(
                          post: post,
                          onLike: () => _handleLike(post),
                          onComment: () => _handleComment(post),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.storeProfile,
                              arguments: StoreProfileRouteArgs(storeId: post.storeId),
                            );
                          },
                        );
                      },
                    ),
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