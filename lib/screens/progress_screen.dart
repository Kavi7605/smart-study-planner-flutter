// lib/screens/progress_screen.dart
// Screen for tracking progress across all subjects

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _selectedSubjectId; // null = show all

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();
    final subjects = provider.subjects;

    // Safety check: ensure the selected subject still exists
    final bool hasValidSelection = _selectedSubjectId != null &&
        subjects.any((s) => s.id == _selectedSubjectId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Subject Filter Chips ──────────────────────────────────────────
          if (subjects.isNotEmpty) _buildSubjectFilterChips(subjects, provider),

          // ── Topic List ────────────────────────────────────────────────────
          Expanded(
            child: !hasValidSelection
                ? _buildAllSubjectsProgress(subjects, provider)
                : _buildSingleSubjectTopics(
                    subjects.firstWhere((s) => s.id == _selectedSubjectId!),
                    provider,
                  ),
          ),
        ],
      ),
    );
  }

  // ── Subject filter horizontal chips ────────────────────────────────────────
  Widget _buildSubjectFilterChips(
      List<SubjectModel> subjects, SubjectProvider provider) {
    // Safety check: ensure the selected subject still exists
    final bool hasValidSelection = _selectedSubjectId != null &&
        subjects.any((s) => s.id == _selectedSubjectId);

    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: !hasValidSelection,
              onSelected: (_) => setState(() => _selectedSubjectId = null),
              selectedColor: AppTheme.primary.withOpacity(0.2),
              checkmarkColor: AppTheme.primary,
            ),
          ),
          ...subjects.map((s) {
            final color = Helpers.parseColor(s.colorHex);
            final isSelected = _selectedSubjectId == s.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s.name),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedSubjectId = s.id),
                selectedColor: color.withOpacity(0.2),
                checkmarkColor: color,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── All subjects progress view ──────────────────────────────────────────────
  Widget _buildAllSubjectsProgress(
      List<SubjectModel> subjects, SubjectProvider provider) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text('No subjects found. Add some from the Subjects tab.',
            style: TextStyle(color: AppTheme.textLight)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 30),
      itemCount: subjects.length,
      itemBuilder: (ctx, i) {
        final subject = subjects[i];
        final topics = provider.getTopicsForSubject(subject.id);
        final completedCount =
            topics.where((t) => t.status == TopicStatus.completed).length;
        final inProgressCount =
            topics.where((t) => t.status == TopicStatus.inProgress).length;
        final percent = provider.getSubjectCompletionPercent(subject.id);
        final color = Helpers.parseColor(subject.colorHex);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      subject.name,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          setState(() => _selectedSubjectId = subject.id),
                      child: const Text('View Topics'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Circular indicator + stats
                Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 45,
                      lineWidth: 8,
                      percent: percent.clamp(0.0, 1.0),
                      center: Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      progressColor: color,
                      backgroundColor: color.withOpacity(0.15),
                      animation: true,
                      animationDuration: 800,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statRow(Icons.check_circle,
                              AppTheme.completedColor, 'Completed',
                              completedCount),
                          const SizedBox(height: 6),
                          _statRow(Icons.timelapse,
                              AppTheme.inProgressColor, 'In Progress',
                              inProgressCount),
                          const SizedBox(height: 6),
                          _statRow(Icons.radio_button_unchecked,
                              AppTheme.notStartedColor, 'Not Started',
                              topics.length - completedCount - inProgressCount),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Single subject topics with status editing ───────────────────────────────
  Widget _buildSingleSubjectTopics(
      SubjectModel subject, SubjectProvider provider) {
    final topics = provider.getTopicsForSubject(subject.id);
    final color = Helpers.parseColor(subject.colorHex);

    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.topic, size: 60, color: color.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text('No topics in this subject.',
                style: TextStyle(color: AppTheme.textLight)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Subject header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: color.withOpacity(0.08),
          child: Text(
            subject.name,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 30),
            itemCount: topics.length,
            itemBuilder: (ctx, i) => _buildTopicStatusCard(topics[i], color, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicStatusCard(
      TopicModel topic, Color subjectColor, SubjectProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark),
                  ),
                ),
                Text(
                  Helpers.formatMinutes(topic.estimatedMinutes),
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textLight),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Status toggle buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusButton(
                  TopicStatus.notStarted,
                  topic.status,
                  AppTheme.notStartedColor,
                  Icons.radio_button_unchecked,
                  () => provider.updateTopicStatus(
                      topic.id, TopicStatus.notStarted),
                ),
                _statusButton(
                  TopicStatus.inProgress,
                  topic.status,
                  AppTheme.inProgressColor,
                  Icons.timelapse,
                  () => provider.updateTopicStatus(
                      topic.id, TopicStatus.inProgress),
                ),
                _statusButton(
                  TopicStatus.completed,
                  topic.status,
                  AppTheme.completedColor,
                  Icons.check_circle,
                  () => provider.updateTopicStatus(
                      topic.id, TopicStatus.completed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String status, String currentStatus, Color color,
      IconData icon, VoidCallback onTap) {
    final isActive = currentStatus == status;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? color : color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, Color color, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
        Text('$count',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
