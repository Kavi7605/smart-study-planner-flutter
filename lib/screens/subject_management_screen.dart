// lib/screens/subject_management_screen.dart
// Screen for adding/managing subjects and their topics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/topic_list_item.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  // Expanded subject id for accordion behavior
  String? _expandedSubjectId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();
    final subjects = provider.subjects;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: subjects.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 100),
              itemCount: subjects.length,
              itemBuilder: (ctx, i) => _buildSubjectAccordion(subjects[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSubjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }

  // ── Subject accordion card ──────────────────────────────────────────────────
  Widget _buildSubjectAccordion(SubjectModel subject) {
    final provider = context.read<SubjectProvider>();
    final topics = provider.getTopicsForSubject(subject.id);
    final color = Helpers.parseColor(subject.colorHex);
    final isExpanded = _expandedSubjectId == subject.id;
    final completedCount =
        topics.where((t) => t.status == 'Completed').length;
    final percent = provider.getSubjectCompletionPercent(subject.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _expandedSubjectId = isExpanded ? null : subject.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Color circle
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '$completedCount/${topics.length} completed  •  ${(percent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                  // Add topic button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    color: color,
                    tooltip: 'Add Topic',
                    onPressed: () => _showAddTopicDialog(context, subject.id),
                  ),
                  // Delete subject button
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 22, color: Colors.red),
                    tooltip: 'Delete Subject',
                    onPressed: () async {
                      final confirm = await Helpers.showConfirmDialog(
                        context,
                        'Delete Subject',
                        'Delete "${subject.name}" and all its topics?',
                      );
                      if (confirm && context.mounted) {
                        context.read<SubjectProvider>().deleteSubject(subject.id);
                      }
                    },
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textLight,
                  ),
                ],
              ),
            ),
          ),
          // Topics list (expandable)
          if (isExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            if (topics.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No topics yet. Tap + to add one.',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                ),
              )
            else
              ...topics.map((topic) => TopicListItem(
                    topic: topic,
                    subjectColor: color,
                    onStatusChange: (newStatus) {
                      context
                          .read<SubjectProvider>()
                          .updateTopicStatus(topic.id, newStatus);
                    },
                    onDelete: () {
                      context.read<SubjectProvider>().deleteTopic(topic.id);
                    },
                  )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 72, color: AppTheme.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No subjects yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to add your first subject',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  // ── Add Subject Dialog ──────────────────────────────────────────────────────
  void _showAddSubjectDialog(BuildContext context) {
    final controller = TextEditingController();
    int selectedColorIndex = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g. Mathematics',
                  prefixIcon: Icon(Icons.book),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Color picker row
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Pick Color:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(
                  SubjectProvider.subjectColors.length,
                  (i) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColorIndex = i),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(SubjectProvider.subjectColors[i]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColorIndex == i
                              ? Colors.black
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  Helpers.showSnackBar(context, 'Please enter a subject name',
                      isError: true);
                  return;
                }
                context
                    .read<SubjectProvider>()
                    .addSubject(name, selectedColorIndex);
                Navigator.pop(ctx);
                Helpers.showSnackBar(context, 'Subject added!');
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Topic Dialog ────────────────────────────────────────────────────────
  void _showAddTopicDialog(BuildContext context, String subjectId) {
    final nameController = TextEditingController();
    final timeController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Topic Name',
                hintText: 'e.g. Quadratic Equations',
                prefixIcon: Icon(Icons.topic),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Estimated Study Time (minutes)',
                hintText: '60',
                prefixIcon: Icon(Icons.access_time),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final minutes = int.tryParse(timeController.text.trim()) ?? 60;
              if (name.isEmpty) {
                Helpers.showSnackBar(context, 'Please enter a topic name',
                    isError: true);
                return;
              }
              context
                  .read<SubjectProvider>()
                  .addTopic(subjectId, name, minutes);
              Navigator.pop(ctx);
              Helpers.showSnackBar(context, 'Topic added!');
              // Keep subject expanded after adding
              setState(() => _expandedSubjectId = subjectId);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
