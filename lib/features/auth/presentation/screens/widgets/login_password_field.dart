import 'package:flutter/material.dart';
import 'package:society_management_app/core/widgets/app_text_field.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String? error;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'Password',
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      errorText: error,
    );
  }
}
