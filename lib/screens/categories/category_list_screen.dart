import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../providers/category_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/entity_list_body.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await context.read<CategoryProvider>().fetchAll();
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  Future<void> _openForm({int? id}) async {
    final saved = await Navigator.pushNamed(
      context,
      AppRoutes.categoryForm,
      arguments: id,
    );
    if (saved == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          return EntityListBody(
            isLoading: provider.isLoading,
            error: provider.error,
            isEmpty: provider.items.isEmpty,
            emptyMessage: 'Nenhuma categoria cadastrada.',
            onRetry: _load,
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  final item = provider.items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('ID: ${item.id}'),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.categoryDetail,
                        arguments: item.id,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(id: item.id),
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
