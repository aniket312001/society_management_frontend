import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class LoginOtpField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final VoidCallback onCompleted;

  const LoginOtpField({
    super.key,
    required this.controller,
    required this.errorMessage,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.contains('OTP');

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Enter 6-digit OTP"),
        const SizedBox(height: 12),
        Pinput(
          controller: controller,
          length: 6,
          defaultPinTheme: defaultPinTheme,
          forceErrorState: hasError,
          onCompleted: (_) => onCompleted(),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
