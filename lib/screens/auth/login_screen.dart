import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              label: 'E-mail',
              controller: emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Senha',
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Entrar',
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
            TextButton(
              onPressed: () {
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