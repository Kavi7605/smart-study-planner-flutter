// lib/screens/schedule_screen.dart
// Screen for scheduling study sessions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/session_provider.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/session_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProv = context.watch<SessionProvider>();
    final subjectProv = context.watch<SubjectProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppTheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'All Sessions'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Upcoming Sessions ───────────────────────────────────────
                _buildSessionList(
                  sessionProv.upcomingSessions,
                  subjectProv,
                  emptyMessage: 'No upcoming sessions.\nTap + to schedule one.',
                ),
                // ── All Sessions ────────────────────────────────────────────
                _buildSessionList(
                  sessionProv.sessions,
                  subjectProv,
                  emptyMessage: 'No sessions yet.\nTap + to schedule one.',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSessionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Schedule Session'),
      ),
    );
  }

  Widget _buildSessionList(
    List sessions,
    SubjectProvider subjectProv, {
    required String emptyMessage,
  }) {
    final sessionProv = context.read<SessionProvider>();

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 64, color: AppTheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: sessions.length,
      itemBuilder: (ctx, i) {
        final session = sessions[i];
        final subject = subjectProv.getSubjectById(session.subjectId);
        final topic = subjectProv.topics
            .where((t) => t.id == session.topicId)
            .firstOrNull;
        return SessionCard(
          session: session,
          subject: subject,
          topic: topic,
          onDelete: () {
            sessionProv.deleteSession(session.id);
            Helpers.showSnackBar(context, 'Session deleted');
          },
        );
      },
    );
  }

  // ── Add Session Bottom Sheet ─────────────────────────────────────────────────
  void _showAddSessionDialog(BuildContext context) {
    final subjectProv = context.read<SubjectProvider>();
    final sessionProv = context.read<SessionProvider>();

    final subjects = subjectProv.subjects;
    if (subjects.isEmpty) {
      Helpers.showSnackBar(context, 'Please add a subject first', isError: true);
      return;
    }

    SubjectModel? selectedSubject = subjects.first;
    TopicModel? selectedTopic;
    List<TopicModel> availableTopics =
        subjectProv.getTopicsForSubject(subjects.first.id);
    if (availableTopics.isNotEmpty) selectedTopic = availableTopics.first;

    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    final durationController = TextEditingController(text: '60');
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Schedule Study Session',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark),
                ),
                const SizedBox(height: 20),

                // Subject picker
                const Text('Subject',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<SubjectModel>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: subjects
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name),
                          ))
                      .toList(),
                  onChanged: (s) {
                    setSheetState(() {
                      selectedSubject = s;
                      availableTopics =
                          subjectProv.getTopicsForSubject(s!.id);
                      selectedTopic = availableTopics.isNotEmpty
                          ? availableTopics.first
                          : null;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Topic picker
                const Text('Topic',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (availableTopics.isEmpty)
                  const Text('No topics in this subject',
                      style: TextStyle(color: AppTheme.textLight))
                else
                  DropdownButtonFormField<TopicModel>(
                    value: selectedTopic,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    items: availableTopics
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name),
                            ))
                        .toList(),
                    onChanged: (t) => setSheetState(() => selectedTopic = t),
                  ),
                const SizedBox(height: 14),

                // Date & Time picker
                const Text('Date & Time',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time == null) return;
                    setSheetState(() {
                      selectedDate = DateTime(
                          date.year, date.month, date.day, time.hour, time.minute);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          Helpers.formatDateTime(selectedDate),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Duration
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedTopic == null || selectedSubject == null) {
                        Helpers.showSnackBar(context,
                            'Please select subject and topic',
                            isError: true);
                        return;
                      }
                      final duration =
                          int.tryParse(durationController.text.trim()) ?? 60;
                      sessionProv.addSession(
                        subjectId: selectedSubject!.id,
                        topicId: selectedTopic!.id,
                        scheduledDate: selectedDate,
                        durationMinutes: duration,
                        notes: notesController.text.trim(),
                      );
                      Navigator.pop(ctx);
                      Helpers.showSnackBar(context, 'Session scheduled!');
                    },
                    child: const Text('Schedule Session'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
