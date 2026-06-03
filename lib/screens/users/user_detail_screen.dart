import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';

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
      appBar: AppBar(
        title: const Text('Detalhes do usuário'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Usuário não encontrado.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(_user!.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('E-mail: ${_user!.email}'),
                      Text('Tipo: ${_user!.userType}'),
                      if (_user!.createdAt != null)
                        Text('Criado em: ${_user!.createdAt}'),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir usuário'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
