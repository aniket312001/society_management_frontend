import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_event.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_state.dart';

/// Show via: CreatePostSheet.show(context, postBloc: bloc);
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
  int get _charCount => _controller.text.length;
  static const _maxChars = 2000;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<PostBloc>().add(CreatePost(text));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostPageLoaded && !state.isError) {
          Navigator.pop(context);
        }
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
            // Header
            Row(
              children: [
                const Text(
                  "New Post",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const Spacer(),
                BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    final isLoading = state is PostFormLoading;
                    return FilledButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: isLoading
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

            // Text field
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 6,
              minLines: 3,
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
          ],
        ),
      ),
    );
  }
}
