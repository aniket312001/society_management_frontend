import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/visitor_entity.dart';
import '../bloc/visitor_bloc.dart';
import '../bloc/visitor_event.dart';
import '../bloc/visitor_state.dart';

class VisitorFormScreen extends StatefulWidget {
  final VisitorEntity? visitor;
  const VisitorFormScreen({super.key, this.visitor});

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _purposeController;
  DateTime? _visitDate;

  bool get _isEdit => widget.visitor != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.visitor?.name ?? '');
    _phoneController = TextEditingController(text: widget.visitor?.phone ?? '');
    _purposeController = TextEditingController(
      text: widget.visitor?.purpose ?? '',
    );
    _visitDate = widget.visitor?.visitDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<VisitorBloc, bool>(
      (b) => b.state is VisitorFormLoading,
    );

    return BlocListener<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state is VisitorPageLoaded && state.message != null) {
          if (state.isError)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.isError ? Colors.red : Colors.green,
              ),
            );
          if (!state.isError) Navigator.pop(context);
        }
        if (state is VisitorFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEdit ? "Edit Visitor" : "Add Visitor")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: "Visitor Name",
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Name is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _phoneController,
                    label: "Phone (optional)",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _purposeController,
                    label: "Purpose (optional)",
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // ─── Date Picker ───────────────────────────────────────────
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Visit Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        errorText:
                            _visitDate == null && _formKey.currentState != null
                            ? "Date is required"
                            : null,
                      ),
                      child: Text(
                        _visitDate != null
                            ? "${_visitDate!.day}/${_visitDate!.month}/${_visitDate!.year}"
                            : "Select a date",
                        style: TextStyle(
                          color: _visitDate != null
                              ? null
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    text: _isEdit ? "Update Visitor" : "Add Visitor",
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  void _submit() {
    // Manually validate date since it's not a FormField
    if (!_formKey.currentState!.validate() || _visitDate == null) {
      if (_visitDate == null) setState(() {}); // trigger error display
      return;
    }

    final entity = VisitorEntity(
      id: widget.visitor?.id ?? 0,
      societyId: widget.visitor?.societyId ?? 0,
      addedBy: widget.visitor?.addedBy ?? 0,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      purpose: _purposeController.text.trim().isEmpty
          ? null
          : _purposeController.text.trim(),
      visitDate: _visitDate!,
      status: widget.visitor?.status ?? "pending",
      createdAt: widget.visitor?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      context.read<VisitorBloc>().add(UpdateVisitor(entity));
    } else {
      context.read<VisitorBloc>().add(CreateVisitor(entity));
    }
  }
}
