import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/detail_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _auth = AuthService();

  bool _codeRequested = false;
  bool _loading = false;
  String? _developmentCode;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showErrorSnackBar(context, 'Informe um e-mail válido.');
      return;
    }
    setState(() => _loading = true);
    try {
      final code = await _auth.requestPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _developmentCode = code;
      });
      showSuccessSnackBar(context, 'Código de recuperação gerado.');
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      showSuccessSnackBar(context, 'Senha alterada. Entre com a nova senha.');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Recuperar senha'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: FormSection(
            title: _codeRequested
                ? 'Defina uma nova senha'
                : 'Encontre sua conta',
            children: [
              Text(
                _codeRequested
                    ? 'Digite o código recebido e escolha uma nova senha.'
                    : 'Informe o e-mail cadastrado para gerar um código de recuperação.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'E-mail',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_codeRequested,
              ),
              if (_codeRequested) ...[
                if (_developmentCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Ambiente de desenvolvimento: código $_developmentCode',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Código de 6 dígitos',
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.trim().length == 6
                      ? null
                      : 'Informe o código de 6 dígitos',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Nova senha',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => (value?.length ?? 0) >= 8
                      ? null
                      : 'Use pelo menos 8 caracteres',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirmar nova senha',
                  controller: _confirmationController,
                  obscureText: true,
                  validator: (value) => value == _passwordController.text
                      ? null
                      : 'As senhas não coincidem',
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(
                text: _codeRequested ? 'Alterar senha' : 'Gerar código',
                isLoading: _loading,
                onPressed: _codeRequested ? _resetPassword : _requestCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
