import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

import '../../domain/entities/society_entity.dart';
import '../../domain/entities/user_entity.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _societyController = TextEditingController();
  final _addressController = TextEditingController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailOtpController = TextEditingController();
  final _phoneOtpController = TextEditingController();

  PhoneNumber phoneNumber = PhoneNumber(isoCode: "IN");

  bool emailVerified = false;
  bool phoneVerified = false;

  bool emailOtpSent = false;
  bool phoneOtpSent = false;

  void sendEmailOtp() {
    context.read<AuthBloc>().add(SendEmailOtp(_emailController.text.trim()));

    setState(() {
      emailOtpSent = true;
    });
  }

  void verifyEmailOtp() {
    context.read<AuthBloc>().add(
      VerifyEmailOtp(
        email: _emailController.text.trim(),
        otp: _emailOtpController.text.trim(),
      ),
    );
  }

  void sendPhoneOtp() {
    context.read<AuthBloc>().add(SendPhoneOtp(_phoneController.text.trim()));

    setState(() {
      phoneOtpSent = true;
    });
  }

  void verifyPhoneOtp() {
    context.read<AuthBloc>().add(
      VerifyPhoneOtp(
        phone: _phoneController.text.trim(),
        otp: _phoneOtpController.text.trim(),
      ),
    );
  }

  void _submit() {
    if (!emailVerified || !phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verify email and phone first")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final society = SocietyEntity(
      id: 0,
      name: _societyController.text.trim(),
      address: _addressController.text.trim(),
      created_at: DateTime.now(),
      status: "pending",
      description: "",
      adminId: 0,
    );

    final admin = UserEntity(
      id: 0,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      society_id: 0,
      role: "admin",
      created_at: DateTime.now(),
      status: "pending",
    );

    context.read<AuthBloc>().add(
      CreateNewSociety(societyEntity: society, userEntity: admin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Register Society")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is EmailOtpVerified) {
            setState(() {
              emailVerified = true;
            });
          }

          if (state is PhoneOtpVerified) {
            setState(() {
              phoneVerified = true;
            });
          }

          if (state is CreateSocietySuccess || state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }

          if (state is CreateSocietyFailure || state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text((state as dynamic).message)));
          }
        },
        builder: (context, state) {
          final isLoading =
              state is CreateSocietyLoading || state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// SOCIETY
                      AppTextField(
                        controller: _societyController,
                        label: "Society Name",
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _addressController,
                        label: "Address",
                        maxLines: 2,
                      ),

                      const SizedBox(height: 25),

                      /// ADMIN NAME
                      AppTextField(
                        controller: _nameController,
                        label: "Admin Name",
                      ),

                      const SizedBox(height: 16),

                      /// EMAIL FIELD
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _emailController,
                              label: "Email",
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: emailVerified ? null : sendEmailOtp,
                            child: Text(
                              emailVerified ? "Verified" : "Send OTP",
                            ),
                          ),
                        ],
                      ),

                      if (emailOtpSent && !emailVerified) ...[
                        const SizedBox(height: 10),
                        Pinput(
                          controller: _emailOtpController,
                          length: 6,
                          defaultPinTheme: otpTheme,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: verifyEmailOtp,
                          child: const Text("Verify Email"),
                        ),
                      ],

                      if (emailVerified)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "✅ Email Verified",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),

                      const SizedBox(height: 20),

                      /// PHONE
                      InternationalPhoneNumberInput(
                        onInputChanged: (value) {},
                        initialValue: phoneNumber,
                        textFieldController: _phoneController,
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.DROPDOWN,
                        ),
                        inputDecoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: phoneVerified ? null : sendPhoneOtp,
                        child: Text(
                          phoneVerified ? "Phone Verified" : "Send Phone OTP",
                        ),
                      ),

                      if (phoneOtpSent && !phoneVerified) ...[
                        const SizedBox(height: 10),
                        Pinput(
                          controller: _phoneOtpController,
                          length: 6,
                          defaultPinTheme: otpTheme,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: verifyPhoneOtp,
                          child: const Text("Verify Phone"),
                        ),
                      ],

                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true,
                      ),

                      const SizedBox(height: 30),

                      AppButton(
                        text: "Create Society",
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
