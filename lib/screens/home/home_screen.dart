import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {
        'title': 'Promocao de Camisetas',
        'description': 'Camisetas com 20% de desconto',
      },
      {
        'title': 'Combo Especial',
        'description': 'Hamburguer + batata + refrigerante',
      },
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(posts[index]['title']!),
              subtitle: Text(posts[index]['description']!),
            ),
          );
        },
      ),
    );
  }
}
