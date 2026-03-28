import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/posts/domain/entities/comment_entities.dart';
import 'package:society_management_app/features/posts/presentation/bloc/comments/comment_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/comments/comment_event.dart';
import 'package:society_management_app/features/posts/presentation/bloc/comments/comment_state.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_bloc.dart';
import 'package:society_management_app/features/posts/presentation/bloc/posts/post_event.dart';

/// Show via:
/// CommentsSheet.show(context, postId: post.id, currentUserId: userId, isAdmin: isAdmin);
class CommentsSheet extends StatelessWidget {
  final int postId;
  final int currentUserId;
  final bool isAdmin;

  const CommentsSheet({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.isAdmin,
  });

  static void show(
    BuildContext context, {
    required int postId,
    required int currentUserId,
    required bool isAdmin,
    required PostBloc postBloc,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: postBloc),
          BlocProvider(
            create: (_) => sl<CommentBloc>()..add(FetchComments(postId)),
          ),
        ],
        child: CommentsSheet(
          postId: postId,
          currentUserId: currentUserId,
          isAdmin: isAdmin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              "Comments",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          // Comment list
          Expanded(
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CommentError) {
                  return Center(child: Text(state.message));
                }
                if (state is CommentLoaded) {
                  if (state.comments.isEmpty) {
                    return const Center(
                      child: Text(
                        "No comments yet. Be the first!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.comments.length,
                    itemBuilder: (_, i) => _CommentTile(
                      comment: state.comments[i],
                      currentUserId: currentUserId,
                      isAdmin: isAdmin,
                      onDelete: () => context.read<CommentBloc>().add(
                        DeleteComment(state.comments[i].id),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // Input
          const Divider(height: 1),
          _CommentInput(
            postId: postId,
            onSubmitted: (count) {
              // Notify PostBloc to bump comment count on the feed card
              context.read<PostBloc>().add(const FetchPosts());
            },
          ),
        ],
      ),
    );
  }
}

// ── Single comment tile ───────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final int currentUserId;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.isAdmin,
    required this.onDelete,
  });

  bool get _canDelete => comment.userId == currentUserId || isAdmin;

  String _initials(String? name) {
    if (name == null || name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    return parts.length >= 2
        ? "${parts[0][0]}${parts[1][0]}".toUpperCase()
        : parts[0][0].toUpperCase();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m";
    if (diff.inDays < 1) return "${diff.inHours}h";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: scheme.secondaryContainer,
            child: Text(
              _initials(comment.authorName),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    comment.content,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          if (_canDelete)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 14,
                color: scheme.onSurface.withOpacity(0.4),
              ),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

// ── Comment input bar ─────────────────────────────────────────────────────────
class _CommentInput extends StatefulWidget {
  final int postId;
  final void Function(int newCount) onSubmitted;

  const _CommentInput({required this.postId, required this.onSubmitted});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<CommentBloc>().add(
      AddComment(postId: widget.postId, content: text),
    );
    _controller.clear();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<CommentBloc, bool>(
      (b) =>
          b.state is CommentLoaded && (b.state as CommentLoaded).isSubmitting,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Write a comment…",
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          isSubmitting
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton.filled(
                  onPressed: () => _submit(context),
                  icon: const Icon(Icons.send_rounded, size: 18),
                ),
        ],
      ),
    );
  }
}
