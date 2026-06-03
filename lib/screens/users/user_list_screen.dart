import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/admin_entity_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/entity_list_body.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await context.read<UserProvider>().fetchAll();
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _openForm({int? id}) async {
    final saved = await Navigator.pushNamed(
      context,
      AppRoutes.userForm,
      arguments: id,
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Usuários'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          return EntityListBody(
            isLoading: provider.isLoading,
            error: provider.error,
            isEmpty: provider.items.isEmpty,
            emptyMessage: 'Nenhum usuário cadastrado.',
            emptyIcon: Icons.people_outline_rounded,
            onRetry: _load,
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = provider.items[index];
                  return AdminEntityCard(
                    title: user.name,
                    subtitle: '${user.email} • ${user.userType}',
                    icon: Icons.person_outline_rounded,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.userDetail,
                      arguments: user.id,
                    ),
                    onEdit: () => _openForm(id: user.id),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
