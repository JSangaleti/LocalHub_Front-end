import 'package:flutter/material.dart';

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
  bool _isLoading = true;
  String? _errorMessage;
  List<PostModel> _posts = [];
  String selectedCategory = 'Todos';
  List<String> categories = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _postService.getPosts();
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
      appBar: AppBar(
        title: const Text('LocalHub'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.storeProfile);
            },
            icon: const Icon(Icons.store),
          ),
        ],
      ),
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
                          onPressed: _loadPosts,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = category == selectedCategory;

                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filteredPosts.isEmpty
                            ? const Center(
                                child: Text('Nenhum post encontrado.'),
                              )
                            : ListView.builder(
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  final post = filteredPosts[index];
                                  return PostCard(
                                    storeName: post.storeName,
                                    title: post.title,
                                    description: post.description,
                                    category: post.category,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}