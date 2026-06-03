import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isEdit = false;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromRoute());
  }

  Future<void> _initFromRoute() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! int) return;

    setState(() {
      _isEdit = true;
      _categoryId = args;
      _isLoading = true;
    });

    try {
      final category =
          await context.read<CategoryProvider>().fetchById(args);
      if (!mounted) return;
      _nameController.text = category.name;
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<CategoryProvider>();
    final name = _nameController.text.trim();

    try {
      if (_isEdit && _categoryId != null) {
        await provider.update(_categoryId!, name);
      } else {
        await provider.create(name);
      }
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        _isEdit ? 'Categoria atualizada.' : 'Categoria cadastrada.',
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar categoria' : 'Nova categoria'),
      ),
      body: _isLoading && _isEdit && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Nome',
                      controller: _nameController,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Nome obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: _isEdit ? 'Salvar' : 'Cadastrar',
                      isLoading: _isLoading,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
