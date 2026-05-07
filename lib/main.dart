// lib/main.dart
// App entry point: initializes Hive, seeds dummy data, sets up providers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/hive_service.dart';
import 'services/dummy_data.dart';
import 'providers/subject_provider.dart';
import 'providers/session_provider.dart';
import 'screens/main_shell.dart';
import 'utils/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open all boxes
  await HiveService.init();

  // Seed dummy data only on first launch
  final hiveService = HiveService();
  await DummyData.seed(hiveService);

  runApp(const SmartStudyPlannerApp());
}

class SmartStudyPlannerApp extends StatelessWidget {
  const SmartStudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register all providers here
      providers: [
        ChangeNotifierProvider(
          create: (_) => SubjectProvider()..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider()..loadData(),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Study Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MainShell(),
      ),
    );
  }
}
