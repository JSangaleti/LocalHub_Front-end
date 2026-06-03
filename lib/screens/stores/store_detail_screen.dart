import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../models/store_model.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';

class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  StoreModel? _store;
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
      final store = await context.read<StoreProvider>().fetchById(id);
      if (mounted) setState(() => _store = store);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (_store == null) return;
    final confirmed = await confirmDelete(
      context,
      message: 'Deseja remover a loja "${_store!.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<StoreProvider>().delete(_store!.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Loja removida.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da loja'),
        actions: [
          if (_store != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await Navigator.pushNamed(
                  context,
                  AppRoutes.storeForm,
                  arguments: _store!.id,
                );
                if (saved == true) _load();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _store == null
              ? const Center(child: Text('Loja não encontrada.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(_store!.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text('Categoria: ${_store!.category}'),
                      Text('Dono (userId): ${_store!.ownerUserId ?? "-"}'),
                      Text('Endereço: ${_store!.address ?? "Não informado"}'),
                      Text('Horário: ${_store!.openingHours ?? "Não informado"}'),
                      Text('Contato: ${_store!.contact ?? "Não informado"}'),
                      if (_store!.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(_store!.description!),
                      ],
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir loja'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
