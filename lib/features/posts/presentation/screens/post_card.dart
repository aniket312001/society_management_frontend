import 'package:flutter/material.dart';
import 'package:society_management_app/core/widgets/image_widget.dart';
import 'package:society_management_app/core/widgets/video_widget.dart';
import 'package:society_management_app/features/posts/domain/entities/post_entities.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final int currentUserId;
  final bool isAdmin;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.isAdmin,
    required this.onLike,
    required this.onComment,
    required this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  bool get _isOwner => widget.post.userId == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _heartCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() => _showHeart = false);
            _heartCtrl.reset();
          }
        });

    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    // Always trigger like animation on double tap
    // If already liked → do nothing to state (already liked)
    // If not liked → trigger like
    if (!widget.post.likedByMe) {
      setState(() => _showHeart = true);
      _heartCtrl.forward();
    }
    widget.onLike();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    _initials(widget.post.authorName),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _timeAgo(widget.post.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isOwner || widget.isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onSelected: (v) {
                      if (v == "delete") widget.onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text("Delete", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // ── Content + Media (double-tap zone) ─────────────────
            const SizedBox(height: 10),
            GestureDetector(
              onDoubleTap: _onDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.content,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      if (widget.post.hasMedia) ...[
                        const SizedBox(height: 10),
                        if (widget.post.isImage)
                          AppImageWidget(url: widget.post.fileUrl!)
                        else if (widget.post.isVideo)
                          AppVideoPlayer(url: widget.post.fileUrl!),
                      ],
                    ],
                  ),

                  // ── Heart burst animation ────────────────────────
                  if (_showHeart)
                    AnimatedBuilder(
                      animation: _heartScale,
                      builder: (_, __) => Transform.scale(
                        scale: _heartScale.value,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 80,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Actions ───────────────────────────────────────────
            const SizedBox(height: 10),
            Row(
              children: [
                _ActionButton(
                  icon: widget.post.likedByMe
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.likedByMe ? Colors.red : null,
                  label: widget.post.likeCount > 0
                      ? widget.post.likeCount.toString()
                      : "Like",
                  onTap: widget.onLike,
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: widget.post.commentCount > 0
                      ? "${widget.post.commentCount} Comments"
                      : "Comment",
                  onTap: widget.onComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.55);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? muted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
