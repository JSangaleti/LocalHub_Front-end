import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../services/auth_service.dart';
import '../screens/stores/store_form_route_args.dart';
import '../screens/store/store_profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final bool hasStore;
  final VoidCallback? onStoreChanged;

  const HomeHeader({
    super.key,
    required this.hasStore,
    this.onStoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isAdmin = user?.userType == 'admin';
    final isLoggedIn = user != null;

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
              onSelected: (value) async {
                if (!context.mounted) return;
                if (value == 'admin') {
                  Navigator.pushNamed(context, AppRoutes.admin);
                  return;
                }
                if (value == 'create_store' && user != null) {
                  final saved = await Navigator.pushNamed(
                    context,
                    AppRoutes.storeForm,
                    arguments: StoreFormRouteArgs(ownerUserId: user.id),
                  );
                  if (!context.mounted) return;
                  if (saved == true) onStoreChanged?.call();
                  return;
                }
                if (value == 'my_store' && user != null) {
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.storeProfile,
                    arguments: StoreProfileRouteArgs(
                      ownerUserId: user.id,
                    ),
                  );
                  if (!context.mounted) return;
                  onStoreChanged?.call();
                  return;
                }
                if (value == 'logout') {
                  AuthService().clearSession();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              itemBuilder: (context) => [
                if (isLoggedIn)
                  const PopupMenuItem(
                    value: 'create_store',
                    child: Text('Criar loja'),
                  ),
                if (hasStore)
                  const PopupMenuItem(
                    value: 'my_store',
                    child: Text('Minha loja'),
                  ),
                if (isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Text('Gerenciar dados'),
                  ),
                const PopupMenuItem(
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
