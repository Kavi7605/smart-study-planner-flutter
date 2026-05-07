// lib/screens/search_screen.dart
// Screen for searching and filtering topics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/topic_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _filterSubjectId; // null = all subjects
  String? _filterStatus;    // null = all statuses

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();

    // Apply filters
    final filtered = _applyFilters(provider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search topics...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // ── Filter Chips Row ──────────────────────────────────────────────
          _buildFilterRow(provider),

          // ── Results count ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} topic(s) found',
                  style: const TextStyle(
                      color: AppTheme.textLight, fontSize: 13),
                ),
                const Spacer(),
                if (_filterSubjectId != null || _filterStatus != null)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off, size: 16),
                    label: const Text('Clear Filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),

          // ── Results List ──────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final topic = filtered[i];
                      final subject = provider.getSubjectById(topic.subjectId);
                      final color = subject != null
                          ? Helpers.parseColor(subject.colorHex)
                          : AppTheme.primary;
                      return _buildTopicResultCard(
                          topic, subject?.name ?? 'Unknown', color, provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Filter row ──────────────────────────────────────────────────────────────
  Widget _buildFilterRow(SubjectProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Subject filter dropdown
            const Text('Subject: ',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight)),
            DropdownButton<String?>(
              value: _filterSubjectId,
              hint: const Text('All', style: TextStyle(fontSize: 13)),
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textDark),
              underline: const SizedBox(),
              onChanged: (val) =>
                  setState(() => _filterSubjectId = val),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All'),
                ),
                ...provider.subjects.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s.id,
                    child: Text(s.name),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Status filter dropdown
            const Text('Status: ',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight)),
            DropdownButton<String?>(
              value: _filterStatus,
              hint: const Text('All', style: TextStyle(fontSize: 13)),
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textDark),
              underline: const SizedBox(),
              onChanged: (val) => setState(() => _filterStatus = val),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All'),
                ),
                DropdownMenuItem<String?>(
                  value: TopicStatus.notStarted,
                  child: Text('Not Started'),
                ),
                DropdownMenuItem<String?>(
                  value: TopicStatus.inProgress,
                  child: Text('In Progress'),
                ),
                DropdownMenuItem<String?>(
                  value: TopicStatus.completed,
                  child: Text('Completed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Topic result card ───────────────────────────────────────────────────────
  Widget _buildTopicResultCard(
    TopicModel topic,
    String subjectName,
    Color color,
    SubjectProvider provider,
  ) {
    final statusColor = AppTheme.statusColor(topic.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(AppTheme.statusIcon(topic.status),
              color: statusColor, size: 20),
        ),
        title: _highlightText(topic.name, _searchQuery),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(subjectName,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textLight)),
                const SizedBox(width: 10),
                const Icon(Icons.access_time,
                    size: 12, color: AppTheme.textLight),
                const SizedBox(width: 2),
                Text(
                  Helpers.formatMinutes(topic.estimatedMinutes),
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textLight),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            topic.status,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor),
          ),
        ),
        onTap: () {
          // Cycle status on tap
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
          provider.updateTopicStatus(topic.id, nextStatus);
          Helpers.showSnackBar(context, 'Status updated to $nextStatus');
        },
      ),
    );
  }

  // ── Highlight matching text ─────────────────────────────────────────────────
  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark));
    }
    final lowerText = text.toLowerCase();
    final start = lowerText.indexOf(query);
    if (start == -1) {
      return Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark));
    }
    final end = start + query.length;
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark),
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              backgroundColor: AppTheme.accent.withOpacity(0.3),
              color: AppTheme.accent,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 64, color: AppTheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No topics found',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
        ],
      ),
    );
  }

  List<TopicModel> _applyFilters(SubjectProvider provider) {
    return provider.topics.where((topic) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          topic.name.toLowerCase().contains(_searchQuery);
      // Subject filter
      final matchesSubject =
          _filterSubjectId == null || topic.subjectId == _filterSubjectId;
      // Status filter
      final matchesStatus =
          _filterStatus == null || topic.status == _filterStatus;
      return matchesSearch && matchesSubject && matchesStatus;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _filterSubjectId = null;
      _filterStatus = null;
    });
  }
}
