import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_decorations.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/detail_widgets.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Meu perfil'),
      body: user == null
          ? Center(
              child: Text(
                'Faça login para ver seu perfil.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DetailHeroCard(
                    title: user.name,
                    subtitle: user.email,
                    icon: Icons.person_rounded,
                    badges: [
                      DetailBadge(label: user.userType),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDecorations.borderRadiusLg,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        DetailInfoRow(
                          icon: Icons.email_outlined,
                          label: 'E-mail',
                          value: user.email,
                        ),
                        DetailInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Tipo de conta',
                          value: user.userType,
                        ),
                        if (user.createdAt != null)
                          DetailInfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Membro desde',
                            value: user.createdAt.toString(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
