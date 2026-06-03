import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/entity_list_body.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = ModalRoute.of(context)?.settings.arguments;
    if (id is! int) return;

    setState(() => _isLoading = true);
    try {
      final user = await context.read<UserProvider>().fetchById(id);
      if (mounted) setState(() => _user = user);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (_user == null) return;
    final confirmed = await confirmDelete(
      context,
      message: 'Deseja remover o usuário "${_user!.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<UserProvider>().delete(_user!.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Usuário removido.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Detalhes do usuário',
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await Navigator.pushNamed(
                  context,
                  AppRoutes.userForm,
                  arguments: _user!.id,
                );
                if (saved == true) _load();
              },
            ),
        ],
      ),
      body: DetailBody(
        isLoading: _isLoading,
        isEmpty: _user == null,
        emptyMessage: 'Usuário não encontrado.',
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DetailHeroCard(
                      title: _user!.name,
                      subtitle: _user!.email,
                      icon: Icons.person_rounded,
                      badges: [
                        DetailBadge(label: _user!.userType),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          DetailInfoRow(
                            icon: Icons.email_outlined,
                            label: 'E-mail',
                            value: _user!.email,
                          ),
                          DetailInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Tipo',
                            value: _user!.userType,
                          ),
                          if (_user!.createdAt != null)
                            DetailInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Criado em',
                              value: _user!.createdAt.toString(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StickyBottomActions(
              children: [
                CustomButton(
                  text: 'Excluir usuário',
                  variant: CustomButtonVariant.destructive,
                  icon: Icons.delete_outline,
                  onPressed: _delete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
