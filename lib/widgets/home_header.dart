import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_decorations.dart';
import '../core/constants/app_routes.dart';
import '../services/auth_service.dart';
import '../screens/stores/store_form_route_args.dart';
import '../screens/store/store_profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final bool hasStore;
  final VoidCallback? onStoreChanged;

  const HomeHeader({super.key, required this.hasStore, this.onStoreChanged});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isAdmin = user?.userType == 'admin';
    final isLoggedIn = user != null;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppDecorations.borderRadiusMd,
              child: Image.asset(
                'assets/images/logo_localhub.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LocalHub',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Descubra perto de você',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: AppDecorations.borderRadiusMd,
                ),
                child: const Icon(Icons.menu_rounded, size: 20),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppDecorations.borderRadiusMd,
              ),
              offset: const Offset(0, 48),
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
                    arguments: StoreProfileRouteArgs(ownerUserId: user.id),
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
                    child: _MenuRow(
                      icon: Icons.add_business_outlined,
                      label: 'Criar loja',
                    ),
                  ),
                if (hasStore)
                  const PopupMenuItem(
                    value: 'my_store',
                    child: _MenuRow(
                      icon: Icons.storefront_outlined,
                      label: 'Minha loja',
                    ),
                  ),
                if (isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: _MenuRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Gerenciar dados',
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: _MenuRow(
                    icon: Icons.logout_rounded,
                    label: 'Sair',
                    destructive: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: AppDecorations.borderRadiusMd,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
