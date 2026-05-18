import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A senha deve ter pelo menos 6 caracteres.',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'As senhas não coincidem.';
      });

      return;
    }

    setState(() {
      _confirmPasswordError = null;
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        accountType: 'cliente',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso.'),
        ),
      );

      Navigator.pop(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível concluir o cadastro.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 700;

          return isLargeScreen
              ? _buildLargeLayout()
              : _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildLargeLayout() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/quadrados2.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.42),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Container(
                  width: 520,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/quadrados.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo_localhub.png',
          width: 210,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 36),

        CustomTextField(
          controller: _nameController,
          label: 'Nome',
        ),

        const SizedBox(height: 14),

        CustomTextField(
          controller: _emailController,
          label: 'E-mail',
        ),

        const SizedBox(height: 14),

        CustomTextField(
          controller: _passwordController,
          label: 'Senha',
          obscureText: true,
        ),

        const SizedBox(height: 14),

        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirmar senha',
            errorText: _confirmPasswordError,
          ),
        ),

        const SizedBox(height: 24),

        CustomButton(
          text: 'Cadastrar',
          isLoading: _isLoading,
          onPressed: _handleRegister,
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Já possui conta? Entrar'),
        ),
      ],
    );
  }
}