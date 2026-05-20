import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/store_model.dart';
import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/store_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Formulário de post para usuário que possui uma loja cadastrada.
class OwnerPostFormScreen extends StatefulWidget {
  const OwnerPostFormScreen({super.key});

  @override
  State<OwnerPostFormScreen> createState() => _OwnerPostFormScreenState();
}

class _OwnerPostFormScreenState extends State<OwnerPostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final StoreService _storeService = StoreService();

  StoreModel? _store;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = AuthService().currentUser;
    if (user == null) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Faça login para publicar posts.');
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final store = await _storeService.resolveForProfile(
        ownerUserId: user.id,
      );
      if (!mounted) return;
      if (store == null) {
        showErrorSnackBar(
          context,
          'Nenhuma loja vinculada ao seu usuário. Cadastre uma loja primeiro.',
        );
        Navigator.pop(context);
        return;
      }
      setState(() => _store = store);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_store == null || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final body = <String, dynamic>{
        'storeId': _store!.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
      };
      if (_store!.categoryId != null) {
        body['categoryId'] = _store!.categoryId;
      }
      final imageUrl = _imageUrlController.text.trim();
      if (imageUrl.isNotEmpty) body['imageUrl'] = imageUrl;

      await context.read<PostProvider>().create(body);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Post publicado.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo post')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _store == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Loja',
                          ),
                          child: Text(
                            _store!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Categoria (da sua loja)',
                          ),
                          child: Text(
                            _store!.category,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Título',
                          controller: _titleController,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Título obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Descrição',
                          controller: _descriptionController,
                          maxLines: 4,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Descrição obrigatória'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'URL da imagem (opcional)',
                          controller: _imageUrlController,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Publicar',
                          isLoading: _isSaving,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
