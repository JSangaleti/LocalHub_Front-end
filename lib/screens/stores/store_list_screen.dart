import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/entity_list_body.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await context.read<StoreProvider>().fetchAll();
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _openForm({int? id}) async {
    final saved = await Navigator.pushNamed(
      context,
      AppRoutes.storeForm,
      arguments: id,
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lojas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<StoreProvider>(
        builder: (context, provider, _) {
          return EntityListBody(
            isLoading: provider.isLoading,
            error: provider.error,
            isEmpty: provider.items.isEmpty,
            emptyMessage: 'Nenhuma loja cadastrada.',
            onRetry: _load,
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  final store = provider.items[index];
                  return Card(
                    child: ListTile(
                      title: Text(store.name),
                      subtitle: Text('${store.category} • ID ${store.id}'),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.storeDetail,
                        arguments: store.id,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(id: store.id),
                      ),
                    ),
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
