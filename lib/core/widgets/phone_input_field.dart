import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final PhoneNumber? initialPhoneNumber;
  final Function(PhoneNumber)? onInputChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.initialPhoneNumber,
    this.onInputChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InternationalPhoneNumberInput(
      onInputChanged: onInputChanged,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DROPDOWN,
        useEmoji: true,
      ),
      initialValue: initialPhoneNumber ?? PhoneNumber(isoCode: 'IN'),
      textFieldController: controller,
      isEnabled: enabled,

      formatInput: true,
      keyboardType: TextInputType.phone,
      validator: validator,
      inputDecoration: InputDecoration(
        labelText: "Phone Number",
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerLowest.withOpacity(0.5),
        hintText: "Phone Number",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
    );
  }
}
