import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String title;
  final Future<bool> Function(String otp) onVerify;

  const OtpVerificationScreen({
    super.key,
    required this.title,
    required this.onVerify,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final pinController = TextEditingController();

  bool loading = false;
  String? error;

  void verify() async {
    setState(() {
      loading = true;
      error = null;
    });

    final success = await widget.onVerify(pinController.text);

    setState(() => loading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() => error = "Invalid OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            Pinput(
              controller: pinController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
            ),

            const SizedBox(height: 20),

            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : verify,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
