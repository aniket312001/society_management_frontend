import 'package:flutter/material.dart';

class LoginModeToggle extends StatelessWidget {
  final bool isPhoneMode;
  final Function(bool) onChanged;

  const LoginModeToggle({
    super.key,
    required this.isPhoneMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('Email')),
        ButtonSegment(value: true, label: Text('Phone')),
      ],
      selected: {isPhoneMode},
      onSelectionChanged: (val) => onChanged(val.first),
    );
  }
}
