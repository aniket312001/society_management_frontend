import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<AppDropdownItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final String? hintText;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      style: TextStyle(
        fontSize: 15,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurfaceVariant.withOpacity(0.4),
      ),
      dropdownColor: colorScheme.surface,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
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
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Simple data class for dropdown items
class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppDropdownItem({required this.value, required this.label, this.icon});
}
