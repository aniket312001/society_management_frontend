import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final void Function(String)? onChanged;
  final String? hintText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.errorText,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        labelStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: const TextStyle(fontSize: 12, height: 1.4),
        errorMaxLines: 2,
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerLowest.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
        ),
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
