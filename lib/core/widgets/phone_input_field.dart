import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(PhoneNumber)? onInputChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InternationalPhoneNumberInput(
      onInputChanged: onInputChanged,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DROPDOWN,
      ),
      initialValue: PhoneNumber(isoCode: 'IN'),
      textFieldController: controller,
      inputDecoration: InputDecoration(
        labelText: "Phone Number",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Phone number required";
        }
        if (value.length < 10) {
          return "Invalid phone number";
        }
        return null;
      },
    );
  }
}
