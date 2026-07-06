import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha e-mail e senha.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(email: email, password: password);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível realizar o login.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 700;

          if (isLargeScreen) {
            return _buildLargeLayout();
          }

          return _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildLargeLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/quadrados2.png', fit: BoxFit.cover),
        ),

        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.42)),
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
                child: _LoginForm(
                  isLoading: _isLoading,
                  compact: false,
                  logoWidth: 220,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onLogin: _handleLogin,
                  onRegister: _goToRegister,
                  onForgotPassword: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/quadrados.png', fit: BoxFit.cover),
        ),

        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),

        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
                child: _LoginForm(
                  isLoading: _isLoading,
                  compact: true,
                  logoWidth: 210,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onLogin: _handleLogin,
                  onRegister: _goToRegister,
                  onForgotPassword: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final bool isLoading;
  final bool compact;
  final double logoWidth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onForgotPassword;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  const _LoginForm({
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onRegister,
    required this.onForgotPassword,
    required this.logoWidth,
    required this.obscurePassword,
    required this.onTogglePassword,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Image.asset(
            'assets/images/logo_localhub.png',
            width: logoWidth,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: compact ? 40 : 36),

        Text(
          'Login',
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: compact ? 22 : 25,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        CustomTextField(label: 'E-mail', controller: emailController),

        const SizedBox(height: 14),

        CustomTextField(
          label: 'Senha',
          controller: passwordController,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
              ),
            onPressed: onTogglePassword,
          ),
        ),

        const SizedBox(height: 22),

        CustomButton(text: 'Entrar', isLoading: isLoading, onPressed: onLogin),

        const SizedBox(height: 12),

        TextButton(
          onPressed: isLoading ? null : onForgotPassword,
          child: const Text('Esqueceu a senha?'),
        ),

        SizedBox(height: compact ? 32 : 28),

        OutlinedButton(
          onPressed: isLoading ? null : onRegister,
          child: const Text('Cadastrar'),
        ),

        const SizedBox(height: 20),

        Text(
          'Admin: ${AppAuth.adminEmail}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
