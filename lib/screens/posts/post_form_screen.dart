import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeIdController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;
  int? _postId;

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
      _postId = args;
      _isLoading = true;
    });

    try {
      final post = await context.read<PostProvider>().fetchById(args);
      if (!mounted) return;
      _storeIdController.text = post.storeId.toString();
      _categoryIdController.text = post.categoryId?.toString() ?? '';
      _titleController.text = post.title;
      _descriptionController.text = post.description;
      _imageUrlController.text = post.imageUrl ?? '';
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _storeIdController.dispose();
    _categoryIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'storeId': int.parse(_storeIdController.text.trim()),
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    };
    final categoryId = int.tryParse(_categoryIdController.text.trim());
    if (categoryId != null && categoryId > 0) {
      body['categoryId'] = categoryId;
    }
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) body['imageUrl'] = imageUrl;
    return body;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<PostProvider>();
    final body = _buildBody();

    try {
      if (_isEdit && _postId != null) {
        await provider.update(_postId!, body);
      } else {
        await provider.create(body);
      }
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        _isEdit ? 'Post atualizado.' : 'Post cadastrado.',
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
      appBar: AppBar(title: Text(_isEdit ? 'Editar post' : 'Novo post')),
      body: _isLoading && _isEdit && _titleController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'ID da loja (storeId)',
                      controller: _storeIdController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final parsed = int.tryParse(v?.trim() ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'ID da loja obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'ID da categoria (opcional)',
                      controller: _categoryIdController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Título',
                      controller: _titleController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Título obrigatório' : null,
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
