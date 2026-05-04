import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../store/store_profile_screen.dart';
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
        password: _passwordController.text.trim(),
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
        const SnackBar(content: Text('Nao foi possivel realizar o login.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              label: 'E-mail',
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Senha',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Entrar',
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
            TextButton(
              onPressed: _isLoading ? null : () {
                Navigator.pushNamed(context, AppRoutes.register);
              },
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}