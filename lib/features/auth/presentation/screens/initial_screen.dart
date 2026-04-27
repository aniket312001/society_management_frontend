// initial_screen.dart
import 'package:flutter/material.dart';
import 'package:society_management_app/core/widgets/icon_button.dart/app_outline_icon_button.dart';
import 'package:society_management_app/core/widgets/icon_button.dart/app_primary_icon_button.dart';
import 'package:society_management_app/features/auth/presentation/screens/register_screen.dart';
import 'login_screen.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.apartment_outlined,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to Society App',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Manage your society easily',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 64),

              AppPrimaryIconButton(
                text: 'Create New Society',
                icon: Icons.add_business,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              AppOutlineIconButton(
                text: 'Already have an account? Login',
                icon: Icons.login,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
