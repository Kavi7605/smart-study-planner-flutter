// lib/widgets/session_card.dart
// Widget for displaying a study session

import 'package:flutter/material.dart';
import '../models/study_session_model.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class SessionCard extends StatelessWidget {
  final StudySessionModel session;
  final SubjectModel? subject;
  final TopicModel? topic;
  final VoidCallback? onDelete;

  const SessionCard({
    super.key,
    required this.session,
    this.subject,
    this.topic,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = subject != null
        ? Helpers.parseColor(subject!.colorHex)
        : AppTheme.primary;

    final isPast = session.scheduledDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left color bar
            Container(
              width: 5,
              height: 70,
              decoration: BoxDecoration(
                color: isPast ? Colors.grey : color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject badge
                  if (subject != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject!.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Topic name
                  Text(
                    topic?.name ?? 'Unknown Topic',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatDateTime(session.scheduledDate),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatMinutes(session.durationMinutes),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textLight),
                      ),
                      if (isPast) ...[
                        const SizedBox(width: 12),
                        const Text(
                          'Past',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                  if (session.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      session.notes,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textLight,
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Delete
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                onPressed: () async {
                  final confirm = await Helpers.showConfirmDialog(
                    context,
                    'Delete Session',
                    'Delete this study session?',
                  );
                  if (confirm) onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }
}
