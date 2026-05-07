// lib/widgets/subject_progress_card.dart
// Widget showing subject name + completion progress bar

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/subject_model.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';

class SubjectProgressCard extends StatelessWidget {
  final SubjectModel subject;
  final double completionPercent; // 0.0 to 1.0
  final int completedCount;
  final int totalCount;
  final VoidCallback? onTap;

  const SubjectProgressCard({
    super.key,
    required this.subject,
    required this.completionPercent,
    required this.completedCount,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Helpers.parseColor(subject.colorHex);
    final percent = completionPercent.clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Color dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Subject name
                  Expanded(
                    child: Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  // Percent label
                  Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Progress bar
              LinearPercentIndicator(
                lineHeight: 10,
                percent: percent,
                backgroundColor: color.withOpacity(0.15),
                progressColor: color,
                barRadius: const Radius.circular(8),
                padding: EdgeInsets.zero,
                animation: true,
                animationDuration: 800,
              ),
              const SizedBox(height: 8),
              Text(
                '$completedCount / $totalCount topics completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
