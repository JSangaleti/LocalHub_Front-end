import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../store/store_profile_screen.dart';

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

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (user.accountType == 'comercio') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.storeProfile,
          arguments: StoreProfileRouteArgs(ownerUserId: user.id),
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
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
            return _buildLargeLayout(context);
          }

          return _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildLargeLayout(BuildContext context) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_localhub.png',
                      width: 220,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 36),

                    CustomTextField(
                      label: 'E-mail',
                      controller: _emailController,
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Senha',
                      controller: _passwordController,
                      obscureText: true,
                    ),

                    const SizedBox(height: 22),

                    CustomButton(
                      text: 'Entrar',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _isLoading ? null : () {},
                      child: const Text('Esqueceu a senha?'),
                    ),

                    const SizedBox(height: 28),

                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              );
                            },
                      child: const Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMobileLayout(BuildContext context) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_localhub.png',
                      width: 210,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 40),

                    CustomTextField(
                      label: 'E-mail',
                      controller: _emailController,
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Senha',
                      controller: _passwordController,
                      obscureText: true,
                    ),

                    const SizedBox(height: 22),

                    CustomButton(
                      text: 'Entrar',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              );
                            },
                      child: const Text('Esqueceu a senha?'),
                    ),

                    const SizedBox(height: 32),

                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              );
                            },
                      child: const Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

class _LoginForm extends StatelessWidget {
  final bool isLoading;
  final bool compact;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _LoginForm({
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onRegister,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) ...[
          Text(
            'Bem-vindo ao LocalHub',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 40,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 48),
        ],
        Text(
          'Login',
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: compact ? 22 : 25,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'E-mail',
          controller: emailController,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Senha',
          controller: passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: 'Entrar',
          isLoading: isLoading,
          onPressed: onLogin,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: isLoading ? null : onRegister,
          child: const Text('Cadastrar'),
        ),
      ],
    );
  }
}