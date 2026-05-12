import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/student_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SmartStudyAdvisorApp());
}

class SmartStudyAdvisorApp extends StatelessWidget {
  const SmartStudyAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentProvider(),
      child: MaterialApp(
        title: 'Smart Study Advisor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
