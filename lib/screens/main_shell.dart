// lib/screens/main_shell.dart
// Main shell widget with bottom navigation bar

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'subject_management_screen.dart';
import 'schedule_screen.dart';
import 'progress_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Screen titles matching bottom nav items
  static const List<String> _titles = [
    'Dashboard',
    'Subjects & Topics',
    'Schedule',
    'Progress',
    'Search',
  ];

  // Screens
  static const List<Widget> _screens = [
    DashboardScreen(),
    SubjectManagementScreen(),
    ScheduleScreen(),
    ProgressScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppInfo(context),
          ),
        ],
      ),
      body: IndexedStack(
        // IndexedStack keeps state of each screen alive
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Study Planner',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.school, color: AppTheme.primary, size: 40),
      children: const [
        Text(
          'A smart study planner and exam preparation tracker built with Flutter + Provider + Hive.',
        ),
        SizedBox(height: 10),
        Text('Features:'),
        Text('• Subject & Topic Management'),
        Text('• Study Session Scheduling'),
        Text('• Progress Tracking'),
        Text('• Search & Filter'),
        Text('• Offline Storage'),
      ],
    );
  }
}
