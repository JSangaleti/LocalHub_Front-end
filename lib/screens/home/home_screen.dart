import 'package:flutter/material.dart';
import 'package:localhub_front/core/constants/app_colors.dart';
import 'package:localhub_front/widgets/category_filter_bar.dart';
import 'package:localhub_front/widgets/home_header.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Todos';
  List<String> categories = ['Todos'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPosts());
  }

  Future<void> _loadPosts() async {
    try {
      await context.read<PostProvider>().fetchAll();
      if (!mounted) return;
      final posts = context.read<PostProvider>().items;
      final mappedCategories = <String>{
        'Todos',
        ...posts.map((post) => post.category),
      }.toList();
      setState(() {
        categories = mappedCategories;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = 'Todos';
        }
      });
    } on ApiException {
      // Erro exibido via provider.error no build
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const HomeHeader(),
          CategoryFilterBar(
            selectedCategory: selectedCategory,
            categories: categories,
            onCategorySelected: (category) {
              setState(() => selectedCategory = category);
            },
          ),
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, provider, _) {
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
                          Text(
                            provider.error!,
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
                  );
                }

                final filteredPosts = selectedCategory == 'Todos'
                    ? provider.items
                    : provider.items
                        .where((post) => post.category == selectedCategory)
                        .toList();

                if (filteredPosts.isEmpty) {
                  return const Center(
                    child: Text('Nenhum post para exibir.'),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.admin),
        icon: const Icon(Icons.settings),
        label: const Text('Gerenciar'),
      ),
    );
  }
}
