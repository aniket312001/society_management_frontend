import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final AnnouncementEntity? announcement;
  const AnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitted = false;

  bool get _isEdit => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.announcement?.title ?? '',
    );
    _bodyController = TextEditingController(
      text: widget.announcement?.body ?? '',
    );
    _startDate = widget.announcement?.startDate;
    _endDate = widget.announcement?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AnnouncementBloc, bool>(
      (b) => b.state is AnnouncementFormLoading,
    );

    return BlocListener<AnnouncementBloc, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementPageLoaded && state.message != null) {
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
        if (state is AnnouncementFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? "Edit Announcement" : "New Announcement"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: "Title",
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Title is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _bodyController,
                    label: "Body",
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Body is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Start Date ─────────────────────────────────────────────
                  _DatePickerField(
                    label: "Start Date",
                    value: _startDate,
                    showError: _submitted && _startDate == null,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    onPicked: (d) => setState(() => _startDate = d),
                  ),
                  const SizedBox(height: 16),

                  // ── End Date ───────────────────────────────────────────────
                  _DatePickerField(
                    label: "End Date",
                    value: _endDate,
                    showError: _submitted && _endDate == null,
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    onPicked: (d) => setState(() => _endDate = d),
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    text: _isEdit ? "Update" : "Create Announcement",
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

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End date must be on or after start date"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entity = AnnouncementEntity(
      id: widget.announcement?.id ?? 0,
      societyId: widget.announcement?.societyId ?? 0,
      createdBy: widget.announcement?.createdBy ?? 0,
      createdByName: widget.announcement?.createdByName,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      createdAt: widget.announcement?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      context.read<AnnouncementBloc>().add(UpdateAnnouncement(entity));
    } else {
      context.read<AnnouncementBloc>().add(CreateAnnouncement(entity));
    }
  }
}

// ── Reusable date picker field ─────────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool showError;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime) onPicked;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.showError,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
  });

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? firstDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today),
          errorText: showError ? "Date is required" : null,
        ),
        child: Text(
          value != null ? _fmt(value!) : "Select a date",
          style: TextStyle(
            color: value != null ? null : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
