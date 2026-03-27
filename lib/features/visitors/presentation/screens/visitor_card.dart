import 'package:flutter/material.dart';
import 'package:society_management_app/features/visitors/domain/entities/visitor_entity.dart';

class VisitorCard extends StatelessWidget {
  final VisitorEntity visitor;
  final bool isAdmin;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final void Function(String currentStatus)? onStatusChange;

  const VisitorCard({
    super.key,
    required this.visitor,
    required this.isAdmin,
    required this.canEdit,
    required this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  Color _statusColor(String status) => switch (status) {
    "approved" => Colors.green,
    "rejected" => Colors.red,
    _ => Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(visitor.status).withOpacity(0.15),
          child: Icon(
            Icons.person_outline,
            color: _statusColor(visitor.status),
          ),
        ),
        title: Text(
          visitor.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visitor.phone != null) Text(visitor.phone!),
            if (visitor.purpose != null)
              Text(
                visitor.purpose!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              "Visit: ${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}",
              style: const TextStyle(fontSize: 12),
            ),
            if (visitor.note != null)
              Text(
                "Note: ${visitor.note}",
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Status badge ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(visitor.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                visitor.status,
                style: TextStyle(
                  fontSize: 11,
                  color: _statusColor(visitor.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // ── Actions menu ─────────────────────────────────────
            if (canEdit || onDelete != null || onStatusChange != null)
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == "edit") onEdit();
                  if (v == "delete") onDelete?.call();
                  if (v == "status") onStatusChange?.call(visitor.status);
                },
                itemBuilder: (_) => [
                  if (canEdit)
                    const PopupMenuItem(value: "edit", child: Text("Edit")),
                  if (isAdmin)
                    const PopupMenuItem(
                      value: "status",
                      child: Text("Change Status"),
                    ),
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
      ),
    );
  }
}
