import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/store_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/empty_state.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<StoreModel> _stores = [];
  int? _selectedStoreId;
  int? _linkedCategoryId;
  String _linkedCategoryName = 'Selecione uma loja';

  bool _isLoading = false;
  bool _loadingStores = true;
  bool _isEdit = false;
  int? _postId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await _loadStores();
    await _initFromRoute();
  }

  Future<void> _loadStores() async {
    setState(() => _loadingStores = true);
    try {
      final provider = context.read<StoreProvider>();
      if (provider.items.isEmpty) {
        await provider.fetchAll();
      }
      if (!mounted) return;
      setState(() {
        _stores = provider.items;
        _loadingStores = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loadingStores = false);
        showErrorSnackBar(context, e.message);
      }
    }
  }

  void _applyStore(StoreModel store) {
    setState(() {
      _selectedStoreId = store.id;
      _linkedCategoryId = store.categoryId;
      _linkedCategoryName = store.category;
    });
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

      _titleController.text = post.title;
      _descriptionController.text = post.description;
      _imageUrlController.text = post.imageUrl ?? '';
      _selectedStoreId = post.storeId;
      _linkedCategoryId = post.categoryId;
      _linkedCategoryName = post.category;

      for (final store in _stores) {
        if (store.id == post.storeId) {
          _applyStore(store);
          break;
        }
      }
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
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

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'storeId': _selectedStoreId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    };
    if (_linkedCategoryId != null) {
      body['categoryId'] = _linkedCategoryId;
    }
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) body['imageUrl'] = imageUrl;
    return body;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStoreId == null) {
      showErrorSnackBar(context, 'Selecione uma loja.');
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<PostProvider>();

    try {
      final body = _buildBody();
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
    if (_loadingStores) {
      return Scaffold(
        appBar: AppHeader(title: _isEdit ? 'Editar post' : 'Novo post'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_stores.isEmpty) {
      return Scaffold(
        appBar: AppHeader(title: _isEdit ? 'Editar post' : 'Novo post'),
        body: EmptyState(
          icon: Icons.storefront_outlined,
          title: 'Nenhuma loja disponível',
          subtitle: 'Cadastre ao menos uma loja antes de criar um post.',
          actionLabel: 'Recarregar lojas',
          onAction: _loadStores,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: _isEdit ? 'Editar post' : 'Novo post'),
      body: _isLoading && _isEdit && _titleController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: FormSection(
                        title: 'Conteúdo do post',
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedStoreId,
                            decoration: const InputDecoration(labelText: 'Loja'),
                            items: _stores
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (id) {
                              if (id == null) return;
                              final store = _stores.firstWhere((s) => s.id == id);
                              _applyStore(store);
                            },
                            validator: (v) =>
                                v == null ? 'Selecione uma loja' : null,
                          ),
                          const SizedBox(height: 16),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Categoria (vinculada à loja)',
                            ),
                            child: Text(
                              _linkedCategoryName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_linkedCategoryId == null && _selectedStoreId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Esta loja não possui categoria vinculada.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
                                    ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Título',
                            controller: _titleController,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Título obrigatório' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Descrição',
                            controller: _descriptionController,
                            maxLines: 4,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Descrição obrigatória'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'URL da imagem (opcional)',
                            controller: _imageUrlController,
                            keyboardType: TextInputType.url,
                            hintText: 'https://...',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                StickyBottomActions(
                  children: [
                    CustomButton(
                      text: _isEdit ? 'Salvar alterações' : 'Publicar post',
                      isLoading: _isLoading,
                      onPressed: _save,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
