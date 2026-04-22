import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../mock/mock_data.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Todos';

  final List<String> categories = ['Todos', 'Roupas', 'Comida', 'Lazer'];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = selectedCategory == 'Todos'
        ? mockPosts
        : mockPosts
            .where((post) => post['category'] == selectedCategory)
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
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
              child: ListView.builder(
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  return PostCard(
                    storeName: post['storeName']!,
                    title: post['title']!,
                    description: post['description']!,
                    category: post['category']!,
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