// lib/screens/dashboard_screen.dart
// Main dashboard showing overall progress and stats

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/session_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/stat_card.dart';
import '../widgets/subject_progress_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjectProv = context.watch<SubjectProvider>();
    final sessionProv = context.watch<SessionProvider>();

    final subjects = subjectProv.subjects;
    final upcomingSessions = sessionProv.upcomingSessions;
    final suggested = subjectProv.suggestedNextTopic;
    final lowestSubject = subjectProv.lowestCompletionSubject;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          subjectProv.loadData();
          sessionProv.loadData();
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            // ── Header Banner ─────────────────────────────────────────────
            _buildHeader(context),

            const SizedBox(height: 20),

            // ── Stats Row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: 'Total Subjects',
                    value: '${subjects.length}',
                    icon: Icons.book,
                    color: AppTheme.primary,
                  ),
                  StatCard(
                    title: 'Completed Topics',
                    value: '${subjectProv.completedTopics}',
                    icon: Icons.check_circle,
                    color: AppTheme.completedColor,
                  ),
                  StatCard(
                    title: 'Pending Topics',
                    value: '${subjectProv.pendingTopics}',
                    icon: Icons.radio_button_unchecked,
                    color: AppTheme.notStartedColor,
                  ),
                  StatCard(
                    title: 'In Progress',
                    value: '${subjectProv.inProgressTopics}',
                    icon: Icons.timelapse,
                    color: AppTheme.inProgressColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Priority Suggestion ───────────────────────────────────────
            if (suggested != null && lowestSubject != null)
              _buildSuggestionBanner(context, lowestSubject.name,
                  suggested.name, Helpers.parseColor(lowestSubject.colorHex)),

            const SizedBox(height: 20),

            // ── Pie Chart ─────────────────────────────────────────────────
            if (subjectProv.totalTopics > 0)
              _buildPieChart(
                subjectProv.completedTopics,
                subjectProv.inProgressTopics,
                subjectProv.pendingTopics,
              ),

            const SizedBox(height: 24),

            // ── Subject Progress ──────────────────────────────────────────
            _sectionHeader(context, 'Subject Progress'),
            const SizedBox(height: 8),
            if (subjects.isEmpty)
              const _EmptyState(message: 'No subjects yet. Add one!')
            else
              ...subjects.map((subject) {
                final topics = subjectProv.getTopicsForSubject(subject.id);
                final completed = topics
                    .where((t) => t.status == 'Completed')
                    .length;
                return SubjectProgressCard(
                  subject: subject,
                  completionPercent:
                      subjectProv.getSubjectCompletionPercent(subject.id),
                  completedCount: completed,
                  totalCount: topics.length,
                );
              }),

            const SizedBox(height: 24),

            // ── Upcoming Sessions ─────────────────────────────────────────
            _sectionHeader(context, 'Upcoming Sessions'),
            const SizedBox(height: 8),
            if (upcomingSessions.isEmpty)
              const _EmptyState(message: 'No upcoming sessions scheduled.')
            else
              ...upcomingSessions.take(3).map((session) {
                final subject = subjectProv.getSubjectById(session.subjectId);
                final topic = subjectProv.topics
                    .where((t) => t.id == session.topicId)
                    .firstOrNull;
                return _UpcomingSessionTile(
                  sessionDate: session.scheduledDate,
                  subjectName: subject?.name ?? 'Unknown',
                  topicName: topic?.name ?? 'Unknown',
                  duration: session.durationMinutes,
                  color: subject != null
                      ? Helpers.parseColor(subject.colorHex)
                      : AppTheme.primary,
                );
              }),
          ],
        ),
      ),
    );
  }

  // ── Header banner with greeting ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting + '! 👋',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Track your study progress today',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ── Priority suggestion banner ──────────────────────────────────────────────
  Widget _buildSuggestionBanner(
      BuildContext context, String subjectName, String topicName, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Next Topic',
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$topicName  •  $subjectName',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pie Chart ───────────────────────────────────────────────────────────────
  Widget _buildPieChart(int completed, int inProgress, int notStarted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Topics Overview',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            if (completed > 0)
                              PieChartSectionData(
                                value: completed.toDouble(),
                                color: AppTheme.completedColor,
                                title: '$completed',
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                radius: 50,
                              ),
                            if (inProgress > 0)
                              PieChartSectionData(
                                value: inProgress.toDouble(),
                                color: AppTheme.inProgressColor,
                                title: '$inProgress',
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                radius: 50,
                              ),
                            if (notStarted > 0)
                              PieChartSectionData(
                                value: notStarted.toDouble(),
                                color: AppTheme.notStartedColor,
                                title: '$notStarted',
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                radius: 50,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Legend
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendDot(AppTheme.completedColor, 'Completed'),
                        const SizedBox(height: 8),
                        _legendDot(AppTheme.inProgressColor, 'In Progress'),
                        const SizedBox(height: 8),
                        _legendDot(AppTheme.notStartedColor, 'Not Started'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark),
      ),
    );
  }
}

// ── Small upcoming session tile ──────────────────────────────────────────────
class _UpcomingSessionTile extends StatelessWidget {
  final DateTime sessionDate;
  final String subjectName;
  final String topicName;
  final int duration;
  final Color color;

  const _UpcomingSessionTile({
    required this.sessionDate,
    required this.subjectName,
    required this.topicName,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            Helpers.formatTime(sessionDate).split(':')[0],
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        title: Text(topicName,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$subjectName  •  ${Helpers.formatDate(sessionDate)}  •  ${Helpers.formatMinutes(duration)}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

// ── Empty state widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(message,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 14)),
      ),
    );
  }
}
