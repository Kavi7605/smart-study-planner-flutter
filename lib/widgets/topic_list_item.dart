// lib/widgets/topic_list_item.dart
// Reusable widget for displaying a topic with status

import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class TopicListItem extends StatelessWidget {
  final TopicModel topic;
  final Color subjectColor;
  final Function(String status)? onStatusChange;
  final VoidCallback? onDelete;

  const TopicListItem({
    super.key,
    required this.topic,
    required this.subjectColor,
    this.onStatusChange,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(topic.status);
    final statusIcon = AppTheme.statusIcon(topic.status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Status icon (tappable to cycle status)
            GestureDetector(
              onTap: () => _cycleStatus(context),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 12),
            // Topic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      decoration: topic.status == TopicStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatMinutes(topic.estimatedMinutes),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                      ),
                      const SizedBox(width: 12),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          topic.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            if (onDelete != null)
              IconButton(
                icon:
                    const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () async {
                  final confirm = await Helpers.showConfirmDialog(
                    context,
                    'Delete Topic',
                    'Are you sure you want to delete "${topic.name}"?',
                  );
                  if (confirm) onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _cycleStatus(BuildContext context) {
    if (onStatusChange == null) return;
    String nextStatus;
    switch (topic.status) {
      case TopicStatus.notStarted:
        nextStatus = TopicStatus.inProgress;
        break;
      case TopicStatus.inProgress:
        nextStatus = TopicStatus.completed;
        break;
      default:
        nextStatus = TopicStatus.notStarted;
    }
    onStatusChange!(nextStatus);
  }
}
