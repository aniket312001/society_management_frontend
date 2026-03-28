import 'package:flutter/material.dart';
import 'package:society_management_app/features/announcements/domain/entities/announcement_entities.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Color _statusColor(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(announcement.startDate)) return Colors.blue;
    if (today.isAfter(announcement.endDate)) return Colors.grey;
    return Colors.green;
  }

  String _statusLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(announcement.startDate)) return "Upcoming";
    if (today.isAfter(announcement.endDate)) return "Expired";
    return "Active";
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(Icons.campaign_outlined, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isAdmin && (onEdit != null || onDelete != null))
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == "edit") onEdit?.call();
                      if (v == "delete") onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: "delete",
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Body ────────────────────────────────────────────────
            Text(
              announcement.body,
              style: const TextStyle(fontSize: 13, height: 1.45),
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── Footer ──────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.date_range, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "${_formatDate(announcement.startDate)} – ${_formatDate(announcement.endDate)}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                if (announcement.createdByName != null) ...[
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    announcement.createdByName!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
