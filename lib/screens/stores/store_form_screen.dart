import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StoreFormScreen extends StatefulWidget {
  const StoreFormScreen({super.key});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerIdController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;
  int? _storeId;

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
      _storeId = args;
      _isLoading = true;
    });

    try {
      final store = await context.read<StoreProvider>().fetchById(args);
      if (!mounted) return;
      _ownerIdController.text = store.ownerUserId?.toString() ?? '';
      _categoryIdController.text = store.categoryId?.toString() ?? '';
      _nameController.text = store.name;
      _descriptionController.text = store.description ?? '';
      _addressController.text = store.address ?? '';
      _hoursController.text = store.openingHours ?? '';
      _contactController.text = store.contact ?? '';
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ownerIdController.dispose();
    _categoryIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  int? _parseRequiredInt(String? value, String field) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  Map<String, dynamic> _buildBody() {
    return {
      'ownerUserId': int.parse(_ownerIdController.text.trim()),
      'categoryId': int.parse(_categoryIdController.text.trim()),
      'name': _nameController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
      if (_hoursController.text.trim().isNotEmpty)
        'openingHours': _hoursController.text.trim(),
      if (_contactController.text.trim().isNotEmpty)
        'contact': _contactController.text.trim(),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<StoreProvider>();
    final body = _buildBody();

    try {
      if (_isEdit && _storeId != null) {
        await provider.update(_storeId!, body);
      } else {
        await provider.create(body);
      }
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        _isEdit ? 'Loja atualizada.' : 'Loja cadastrada.',
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _requiredIntValidator(String? value, String label) {
    final parsed = _parseRequiredInt(value, label);
    if (parsed == null) return '$label obrigatório (número válido)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar loja' : 'Nova loja')),
      body: _isLoading && _isEdit && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'ID do dono (ownerUserId)',
                      controller: _ownerIdController,
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredIntValidator(v, 'Dono'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'ID da categoria (categoryId)',
                      controller: _categoryIdController,
                      keyboardType: TextInputType.number,
                      validator: (v) => _requiredIntValidator(v, 'Categoria'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Nome da loja',
                      controller: _nameController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Descrição',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Endereço',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Horário de funcionamento',
                      controller: _hoursController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Contato',
                      controller: _contactController,
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
