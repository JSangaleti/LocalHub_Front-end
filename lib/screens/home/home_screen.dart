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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const HomeHeader(),

          CategoryFilterBar(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: (category){
              setState(() {
                selectedCategory = category;
              });
            }
          ),

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
