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
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  DateTime? _startDate;
  DateTime? _endDate;

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
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? _formatDate(_endDate!) : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
        // Clear end date if it's now before the new start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          _endDateController.clear();
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

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
                    prefixIcon: const Icon(Icons.title_outlined),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Title is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _bodyController,
                    label: "Body",
                    prefixIcon: const Icon(Icons.notes_outlined),
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Body is required"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Start Date ─────────────────────────────────────
                  AppTextField(
                    controller: _startDateController,
                    label: "Start Date",
                    readOnly: true,
                    onTap: _pickStartDate,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    hintText: "Select start date",
                    validator: (_) =>
                        _startDate == null ? "Start date is required" : null,
                  ),
                  const SizedBox(height: 16),

                  // ── End Date ───────────────────────────────────────
                  AppTextField(
                    controller: _endDateController,
                    label: "End Date",
                    readOnly: true,
                    onTap: _pickEndDate,
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    hintText: "Select end date",
                    validator: (_) =>
                        _endDate == null ? "End date is required" : null,
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
}
