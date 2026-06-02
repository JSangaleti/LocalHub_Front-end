import 'package:flutter/material.dart';
import 'package:localhub_front/core/constants/app_colors.dart';
import 'package:localhub_front/widgets/category_filter_bar.dart';
import 'package:localhub_front/widgets/home_header.dart';

import '../../core/constants/app_routes.dart';
import '../../models/post_model.dart';
import '../../services/api_service.dart';
import '../../services/post_service.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  List<PostModel> _posts = [];
  String selectedCategory = 'Todos';
  List<String> categories = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({String? search}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _postService.getPosts(search: search);
      final mappedCategories = <String>{
        'Todos',
        ...posts.map((post) => post.category),
      }.toList();

      if (!mounted) return;
      setState(() {
        _posts = posts;
        categories = mappedCategories;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = 'Todos';
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Nao foi possivel carregar o feed.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = selectedCategory == 'Todos'
        ? _posts
        : _posts
            .where((post) => post.category == selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const HomeHeader(),

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
                          setState(() {
                            _searchQuery = '';
                          });
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) {
                _loadPosts(search: _searchQuery);
              },
            ),
          ),

          CategoryFilterBar(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: (category){
              setState(() {
                selectedCategory = category;
              });
              // re-run the search with the current query when category changes
              _loadPosts(search: _searchQuery);
            }
          ),

          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Text(_errorMessage!),
              ),
            )
          else
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index){
                    final post = filteredPosts[index];
                    return PostCard(
                      storeName: post.storeName,
                      title: post.title,
                      description: post.description,
                      category: post.category);
                  },
                )
              ),
            )

        ],
      )
    );
  }
}
