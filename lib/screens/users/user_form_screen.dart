import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/detail_widgets.dart';
import '../../widgets/image_picker_field.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _api = ApiService();

  XFile? _pickedImage;
  String? _currentImageUrl;

  bool _isLoading = false;
  bool _isEdit = false;
  int? _userId;
  String _userType = 'cliente';

  static const _userTypesClienteComercio = ['cliente', 'comercio'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromRoute());
  }

  Future<void> _initFromRoute() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! int) return;

    setState(() {
      _isEdit = true;
      _userId = args;
      _isLoading = true;
    });

    try {
      final user = await context.read<UserProvider>().fetchById(args);
      if (!mounted) return;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _userType = user.userType;
      setState(() => _currentImageUrl = user.profileImageUrl);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<UserProvider>();

    try {
      int userId;
      if (_isEdit && _userId != null) {
        final body = <String, dynamic>{
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': _userType,
        };
        final password = _passwordController.text;
        if (password.isNotEmpty) body['password'] = password;
        await provider.update(_userId!, body);
        userId = _userId!;
      } else {
        final created = await provider.create(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          userType: _userType,
        );
        userId = created.id;
      }

      if (_pickedImage != null) {
        await _api.uploadFile('/uploads/users/$userId', _pickedImage!);
      }

      if (!mounted) return;
      showSuccessSnackBar(
        context,
        _isEdit ? 'Usuário atualizado.' : 'Usuário cadastrado.',
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
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: _isEdit ? 'Editar usuário' : 'Novo usuário',
      ),
      body: _isLoading && _isEdit && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: FormSection(
                        title: 'Informações do usuário',
                        children: [
                          CustomTextField(
                            label: 'Nome',
                            controller: _nameController,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'E-mail',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'E-mail obrigatório';
                              }
                              if (!v.contains('@')) return 'E-mail inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: _isEdit ? 'Nova senha (opcional)' : 'Senha',
                            controller: _passwordController,
                            obscureText: true,
                            validator: (v) {
                              if (!_isEdit && (v == null || v.length < 6)) {
                                return 'Senha deve ter pelo menos 6 caracteres';
                              }
                              if (_isEdit && v != null && v.isNotEmpty && v.length < 6) {
                                return 'Senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _userType,
                            decoration: const InputDecoration(labelText: 'Tipo de usuário'),
                            items: (_isEdit && _userType == 'admin'
                                    ? ['admin', ..._userTypesClienteComercio]
                                    : _userTypesClienteComercio)
                                .map(
                                  (t) => DropdownMenuItem(value: t, child: Text(t)),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _userType = v);
                            },
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
                    ),
                  ),
                ),
                StickyBottomActions(
                  children: [
                    CustomButton(
                      text: _isEdit ? 'Salvar alterações' : 'Cadastrar usuário',
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
