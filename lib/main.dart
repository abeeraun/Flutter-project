import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'repositories/subject_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/exam_repository.dart';
import 'repositories/dashboard_repository.dart';
import 'providers/subject_provider.dart';
import 'providers/task_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() {
  final apiService = ApiService();
  final subjectRepository = SubjectRepository(apiService);
  final taskRepository = TaskRepository(apiService);
  final examRepository = ExamRepository(apiService);
  final dashboardRepository = DashboardRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectProvider(subjectRepository)),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
        ChangeNotifierProvider(create: (_) => ExamProvider(examRepository)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(dashboardRepository)),
      ],
      child: const StudyFlowApp(),
    ),
  );
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: RootShell(),
      ),
    );
  }
}
