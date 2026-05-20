import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('Usuários', Icons.person_outline, AppRoutes.userList),
      ('Lojas', Icons.store_outlined, AppRoutes.storeList),
      ('Categorias', Icons.category_outlined, AppRoutes.categoryList),
      ('Posts', Icons.article_outlined, AppRoutes.postList),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar dados')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final (title, icon, route) = entries[index];
          return Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, route),
            ),
          );
        },
      ),
    );
  }
}
