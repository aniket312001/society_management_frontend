import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:society_management_app/core/widgets/app_text_field.dart';

class LoginIdentifierField extends StatelessWidget {
  final bool isPhoneMode;
  final TextEditingController emailController;
  final PhoneNumber phoneNumber;
  final Function(PhoneNumber) onPhoneChanged;
  final Function(bool) onPhoneValidated;
  final String? error;
  final bool showError;

  const LoginIdentifierField({
    super.key,
    required this.isPhoneMode,
    required this.emailController,
    required this.phoneNumber,
    required this.onPhoneChanged,
    required this.onPhoneValidated,
    required this.error,
    required this.showError,
  });

  @override
  Widget build(BuildContext context) {
    if (isPhoneMode) {
      return InternationalPhoneNumberInput(
        onInputChanged: onPhoneChanged,
        onInputValidated: onPhoneValidated,
        initialValue: phoneNumber,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          useEmoji: true,
        ),
        inputDecoration: InputDecoration(
          labelText: 'Phone Number',
          border: const OutlineInputBorder(),
          errorText: showError ? error : null,
        ),
      );
    }

    return AppTextField(
      controller: emailController,
      label: 'Email Address',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
      errorText: showError ? error : null,
    );
  }
}
