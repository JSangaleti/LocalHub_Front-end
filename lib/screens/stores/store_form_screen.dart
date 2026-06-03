import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/category_dropdown_field.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'store_form_route_args.dart';

class StoreFormScreen extends StatefulWidget {
  const StoreFormScreen({super.key});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _contactController = TextEditingController();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _loadingCategories = true;
  bool _isEdit = false;
  bool _lockOwnerId = false;
  int? _storeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  StoreFormRouteArgs? _readCreateArgs() {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is StoreFormRouteArgs) return raw;
    return null;
  }

  Future<void> _bootstrap() async {
    await _loadCategories();
    _applyCreateArgs();
    await _initFromRoute();
  }

  void _applyCreateArgs() {
    final args = _readCreateArgs();
    if (args == null) {
      final user = AuthService().currentUser;
      if (user != null) {
        _ownerIdController.text = user.id.toString();
        _lockOwnerId = true;
      }
      return;
    }
    _ownerIdController.text = args.ownerUserId.toString();
    _lockOwnerId = args.lockOwnerId;
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final provider = context.read<CategoryProvider>();
      if (provider.items.isEmpty) {
        await provider.fetchAll();
      }
      if (!mounted) return;
      setState(() {
        _categories = provider.items;
        _loadingCategories = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loadingCategories = false);
        showErrorSnackBar(context, e.message);
      }
    }
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
      _selectedCategoryId = store.categoryId;
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
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    return {
      'ownerUserId': int.parse(_ownerIdController.text.trim()),
      'categoryId': _selectedCategoryId,
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

    try {
      if (_isEdit && _storeId != null) {
        await provider.update(_storeId!, _buildBody());
      } else {
        await provider.create(_buildBody());
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
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return '$label obrigatório (número válido)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCategories) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Editar loja' : 'Nova loja')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Editar loja' : 'Nova loja')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cadastre ao menos uma categoria antes de criar uma loja.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadCategories,
                  child: const Text('Recarregar categorias'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                    if (!_lockOwnerId)
                      CustomTextField(
                        label: 'ID do dono (ownerUserId)',
                        controller: _ownerIdController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _requiredIntValidator(v, 'Dono'),
                      )
                    else
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Dono da loja (você)',
                        ),
                        child: Text(
                          _ownerIdController.text,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 12),
                    CategoryDropdownField(
                      categories: _categories,
                      value: _selectedCategoryId,
                      onChanged: (id) =>
                          setState(() => _selectedCategoryId = id),
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
