import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:society_management_app/features/user/presentation/bloc/user_event.dart';
import 'package:society_management_app/features/user/presentation/bloc/user_state.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/phone_input_field.dart';

class UserFormScreen extends StatefulWidget {
  final UserEntity? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  String role = "member";
  PhoneNumber? phoneNumber; // For international phone

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? "");
    emailController = TextEditingController(text: widget.user?.email ?? "");
    phoneController = TextEditingController(text: widget.user?.phone ?? "");

    role = widget.user?.role ?? "member";

    // Initialize phone number for editing
    if (widget.user?.phone != null && widget.user!.phone!.isNotEmpty) {
      phoneNumber = PhoneNumber(isoCode: 'IN', phoneNumber: widget.user!.phone);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    final isLoading = context.select<UserBloc, bool>(
      (bloc) => bloc.state is UserFormLoading,
    );

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserPageLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.isError ? Colors.red : Colors.green,
            ),
          );

          if (!state.isError) {
            Navigator.pop(context);
          }
        }

        if (state is UserFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(isEdit ? "Update User" : "Add New User")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: nameController,
                    label: "Full Name",
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Name is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email - Disabled in Edit Mode
                  AppTextField(
                    controller: emailController,
                    label: "Email Address",
                    enabled: !isEdit,
                    keyboardType: TextInputType.emailAddress,
                    validator: isEdit
                        ? null
                        : (v) => v == null || v.trim().isEmpty
                              ? "Email is required"
                              : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone - Using International Phone Input
                  PhoneInputField(
                    controller: phoneController,

                    initialPhoneNumber: phoneNumber,
                    enabled: !isEdit,
                    onInputChanged: (PhoneNumber number) {
                      phoneNumber = number;
                    },
                    validator: isEdit
                        ? null
                        : (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone number is required";
                            }
                            if (value.length < 10) {
                              return "Invalid phone number";
                            }
                            return null;
                          },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "member", child: Text("Member")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (value) => setState(() => role = value!),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    text: isEdit ? "Update User" : "Create User",
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              isEdit ? _updateUser() : _addUser();
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addUser() {
    final phone = phoneNumber?.phoneNumber ?? phoneController.text.trim();

    context.read<UserBloc>().add(
      CreateUser(
        UserEntity(
          id: 0,
          name: nameController.text.trim(),
          email: emailController.text.trim().toLowerCase(),
          phone: phone,
          password: "",
          society_id: 0,
          role: role,
          created_at: DateTime.now(),
          status: "pending",
        ),
      ),
    );
  }

  void _updateUser() {
    context.read<UserBloc>().add(
      UpdateUserStatus(
        widget.user!.copyWith(
          name: nameController.text.trim(),
          role: role,
          // Email and Phone remain unchanged in edit mode
        ),
        widget.user!.status,
      ),
    );
  }
}
