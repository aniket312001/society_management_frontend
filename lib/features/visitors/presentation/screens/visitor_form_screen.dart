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
  late final TextEditingController _dateController;
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
    _dateController = TextEditingController(
      text: _visitDate != null ? _formatDate(_visitDate!) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

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

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<VisitorBloc, bool>(
      (b) => b.state is VisitorFormLoading,
    );

    return BlocListener<VisitorBloc, VisitorState>(
      listener: (context, state) {
        if (state is VisitorPageLoaded && state.message != null) {
          if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            Navigator.pop(context);
          }
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
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Name is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _phoneController,
                    label: "Phone (optional)",
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _purposeController,
                    label: "Purpose (optional)",
                    prefixIcon: const Icon(Icons.info_outline),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // ── Date picker using AppTextField ─────────────────
                  AppTextField(
                    controller: _dateController,
                    label: "Visit Date",
                    readOnly: true,
                    onTap: _pickDate,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    hintText: "Select a date",
                    validator: (_) =>
                        _visitDate == null ? "Visit date is required" : null,
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
}
