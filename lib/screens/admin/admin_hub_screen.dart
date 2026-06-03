import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../widgets/admin_entity_card.dart';
import '../../widgets/app_header.dart';

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      (
        'Usuários',
        'Gerenciar contas e permissões',
        Icons.people_outline_rounded,
        AppRoutes.userList,
      ),
      (
        'Lojas',
        'Cadastrar e editar comércios',
        Icons.storefront_outlined,
        AppRoutes.storeList,
      ),
      (
        'Categorias',
        'Organizar tipos de negócio',
        Icons.grid_view_rounded,
        AppRoutes.categoryList,
      ),
      (
        'Posts',
        'Moderar publicações',
        Icons.article_outlined,
        AppRoutes.postList,
      ),
    ];

    return Scaffold(
      appBar: const AppHeader(title: 'Gerenciar dados'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (title, subtitle, icon, route) = entries[index];
          return AdminHubCard(
            title: title,
            subtitle: subtitle,
            icon: icon,
            onTap: () => Navigator.pushNamed(context, route),
          );
        },
      ),
    );
  }
}
