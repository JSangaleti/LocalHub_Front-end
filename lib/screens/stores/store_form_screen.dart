import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/cnpj_utils.dart';
import '../../utils/contact_utils.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/category_dropdown_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/image_picker_field.dart';
import 'store_form_route_args.dart';

class StoreFormScreen extends StatefulWidget {
  const StoreFormScreen({super.key});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerIdController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingHourController = TextEditingController();
  final _openingMinuteController = TextEditingController();
  final _closingHourController = TextEditingController();
  final _closingMinuteController = TextEditingController();
  final _contactController = TextEditingController();
  final _api = ApiService();

  XFile? _pickedImage;
  String? _currentImageUrl;

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _loadingCategories = true;
  bool _isEdit = false;
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
      }
      return;
    }
    _ownerIdController.text = args.ownerUserId.toString();
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
      _cnpjController.text = formatCnpj(store.cnpj ?? '');
      _nameController.text = store.name;
      _descriptionController.text = store.description ?? '';
      _addressController.text = store.address ?? '';
      _applyOpeningHours(store.openingHours);
      _contactController.text = formatBrazilianPhone(store.contact ?? '');
      _currentImageUrl = store.profileImageUrl;

      final user = AuthService().currentUser;
      if (user == null ||
          (user.userType != 'admin' && store.ownerUserId != user.id)) {
        showErrorSnackBar(context, 'Apenas o dono da loja pode editá-la.');
        Navigator.pop(context);
        return;
      }
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ownerIdController.dispose();
    _cnpjController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _openingHourController.dispose();
    _openingMinuteController.dispose();
    _closingHourController.dispose();
    _closingMinuteController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    return {
      'ownerUserId': int.parse(_ownerIdController.text.trim()),
      'categoryId': _selectedCategoryId,
      'cnpj': normalizeCnpj(_cnpjController.text),
      'name': _nameController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
      if (_buildOpeningHours() != null) 'openingHours': _buildOpeningHours(),
      if (_contactController.text.trim().isNotEmpty)
        'contact': _contactController.text.trim(),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<StoreProvider>();

    try {
      int storeId;
      if (_isEdit && _storeId != null) {
        await provider.update(_storeId!, _buildBody());
        storeId = _storeId!;
      } else {
        final created = await provider.create(_buildBody());
        storeId = created.id;
      }

      if (_pickedImage != null) {
        await _api.uploadFile('/uploads/stores/$storeId', _pickedImage!);
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

  void _applyOpeningHours(String? value) {
    final match = RegExp(
      r'(\d{1,2}):(\d{2}).*?(\d{1,2}):(\d{2})',
    ).firstMatch(value ?? '');
    if (match == null) return;
    _openingHourController.text = match.group(1)!;
    _openingMinuteController.text = match.group(2)!;
    _closingHourController.text = match.group(3)!;
    _closingMinuteController.text = match.group(4)!;
  }

  String? _buildOpeningHours() {
    final values = [
      _openingHourController.text.trim(),
      _openingMinuteController.text.trim(),
      _closingHourController.text.trim(),
      _closingMinuteController.text.trim(),
    ];
    if (values.every((value) => value.isEmpty)) return null;
    String two(String value) => value.padLeft(2, '0');
    return '${two(values[0])}:${two(values[1])} - '
        '${two(values[2])}:${two(values[3])}';
  }

  String? _timeValidator(String? value, int max, String label) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0 || parsed > max) {
      return '$label inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCategories) {
      return Scaffold(
        appBar: AppHeader(title: _isEdit ? 'Editar loja' : 'Nova loja'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppHeader(title: _isEdit ? 'Editar loja' : 'Nova loja'),
        body: EmptyState(
          icon: Icons.category_outlined,
          title: 'Nenhuma categoria disponível',
          subtitle: 'Cadastre ao menos uma categoria antes de criar uma loja.',
          actionLabel: 'Recarregar categorias',
          onAction: _loadCategories,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: _isEdit ? 'Editar loja' : 'Nova loja'),
      body: _isLoading && _isEdit && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormSection(
                            title: 'Dados da loja',
                            children: [
                              CategoryDropdownField(
                                categories: _categories,
                                value: _selectedCategoryId,
                                onChanged: (id) =>
                                    setState(() => _selectedCategoryId = id),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'CNPJ',
                                controller: _cnpjController,
                                keyboardType: TextInputType.number,
                                hintText: '00.000.000/0000-00',
                                inputFormatters: [CnpjInputFormatter()],
                                validator: (v) => validateCnpjField(v),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Nome da loja',
                                controller: _nameController,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Nome obrigatório'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Descrição',
                                controller: _descriptionController,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              ImagePickerField(
                                label: 'Foto de perfil (opcional)',
                                currentImageUrl: _currentImageUrl,
                                onChanged: (file) =>
                                    setState(() => _pickedImage = file),
                              ),
                            ],
                          ),
                          FormSection(
                            title: 'Localização e contato',
                            children: [
                              CustomTextField(
                                label: 'Endereço',
                                controller: _addressController,
                              ),
                              const SizedBox(height: 16),
                              _TimeFields(
                                openingHourController: _openingHourController,
                                openingMinuteController:
                                    _openingMinuteController,
                                closingHourController: _closingHourController,
                                closingMinuteController:
                                    _closingMinuteController,
                                validator: _timeValidator,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Contato',
                                controller: _contactController,
                                keyboardType: TextInputType.phone,
                                hintText: '(00) 00000-0000',
                                inputFormatters: [
                                  BrazilianPhoneInputFormatter(),
                                ],
                                validator: (value) {
                                  final length = normalizeBrazilianPhone(
                                    value ?? '',
                                  ).length;
                                  return length == 11
                                      ? null
                                      : 'Informe DDD e celular com 11 dígitos';
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                StickyBottomActions(
                  children: [
                    CustomButton(
                      text: _isEdit ? 'Salvar alterações' : 'Cadastrar loja',
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

class _TimeFields extends StatelessWidget {
  final TextEditingController openingHourController;
  final TextEditingController openingMinuteController;
  final TextEditingController closingHourController;
  final TextEditingController closingMinuteController;
  final String? Function(String?, int, String) validator;

  const _TimeFields({
    required this.openingHourController,
    required this.openingMinuteController,
    required this.closingHourController,
    required this.closingMinuteController,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    Widget field(String label, TextEditingController controller, int max) {
      return Expanded(
        child: CustomTextField(
          label: label,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          validator: (value) => validator(value, max, label),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            field('Abre (hora)', openingHourController, 23),
            const SizedBox(width: 8),
            field('Abre (min)', openingMinuteController, 59),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            field('Fecha (hora)', closingHourController, 23),
            const SizedBox(width: 8),
            field('Fecha (min)', closingMinuteController, 59),
          ],
        ),
      ],
    );
  }
}
