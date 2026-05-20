import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  CategoryModel? _category;
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
      final category =
          await context.read<CategoryProvider>().fetchById(id);
      if (mounted) setState(() => _category = category);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (_category == null) return;
    final confirmed = await confirmDelete(
      context,
      message: 'Deseja remover a categoria "${_category!.name}"?',
    );
    if (!confirmed || !mounted) return;

    try {
      await context.read<CategoryProvider>().delete(_category!.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Categoria removida.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da categoria'),
        actions: [
          if (_category != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await Navigator.pushNamed(
                  context,
                  AppRoutes.categoryForm,
                  arguments: _category!.id,
                );
                if (saved == true) _load();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _category == null
              ? const Center(child: Text('Categoria não encontrada.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _category!.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text('ID: ${_category!.id}'),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Excluir categoria'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
