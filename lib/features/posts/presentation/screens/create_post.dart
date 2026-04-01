import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_management_app/core/storage/media_upload_service.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_event.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_state.dart';
import 'package:society_management_app/features/posts/presentation/screens/widgets/attach_btn.dart';
import 'package:society_management_app/features/posts/presentation/screens/widgets/local_media_preview.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  static void show(BuildContext context, {required PostBloc postBloc}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          BlocProvider.value(value: postBloc, child: const CreatePostSheet()),
    );
  }

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();

  File? _pickedFile;
  String? _fileType;
  bool _isUploading = false;

  static const _maxChars = 2000;
  int get _charCount => _controller.text.length;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Pick ──────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _pickedFile = File(picked.path);
      _fileType = 'image';
    });
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _pickedFile = File(picked.path);
      _fileType = 'video';
    });
  }

  void _removeFile() => setState(() {
    _pickedFile = null;
    _fileType = null;
  });

  // ── Upload + Submit ───────────────────────────────────────────────
  Future<void> _submit(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pickedFile == null) return;

    String? fileUrl;

    if (_pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        fileUrl = await MediaUploadService.upload(_pickedFile!, _fileType!);
      } catch (e) {
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      if (mounted) setState(() => _isUploading = false);
    }

    if (context.mounted) {
      context.read<PostBloc>().add(
        CreatePost(text, fileUrl: fileUrl, fileType: _fileType),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostPageLoaded && !state.isError) Navigator.pop(context);
        if (state is PostPageLoaded && state.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is PostFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  "New Post",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const Spacer(),
                BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    final busy = state is PostFormLoading || _isUploading;
                    return FilledButton(
                      onPressed: busy ? null : () => _submit(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Post"),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Text field ────────────────────────────────────────
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 4,
              minLines: 2,
              maxLength: _maxChars,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                filled: true,
                fillColor: scheme.surfaceVariant.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterStyle: TextStyle(
                  color: _charCount > _maxChars - 100
                      ? Colors.red
                      : scheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Local preview ─────────────────────────────────────
            if (_pickedFile != null)
              LocalMediaPreview(
                file: _pickedFile!,
                fileType: _fileType!,
                onRemove: _removeFile,
                isUploading: _isUploading,
              ),

            const SizedBox(height: 8),

            // ── Attach buttons ────────────────────────────────────
            if (_pickedFile == null)
              Row(
                children: [
                  AttachBtn(
                    icon: Icons.image_outlined,
                    label: "Photo",
                    onTap: _pickImage,
                  ),
                  const SizedBox(width: 8),
                  AttachBtn(
                    icon: Icons.videocam_outlined,
                    label: "Video",
                    onTap: _pickVideo,
                  ),
                ],
              ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
