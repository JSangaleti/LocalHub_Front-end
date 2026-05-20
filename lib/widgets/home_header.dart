import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo_localhub.png',
              height: 42,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.view_headline),
              onSelected: (value) {
                if (value == 'admin') {
                  Navigator.pushNamed(context, AppRoutes.admin);
                }
                if (value == 'profile') {
                  Navigator.pushNamed(context, AppRoutes.storeProfile);
                }
                if (value == 'logout') {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'admin',
                  child: Text('Gerenciar dados'),
                ),
                PopupMenuItem(
                  value: 'profile',
                  child: Text('Perfil do Usuário'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Sair'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
