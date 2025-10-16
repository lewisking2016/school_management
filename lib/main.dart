import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_management/attendance_management_screen.dart';
import 'package:school_management/firebase_options.dart';
import 'package:school_management/log_in_screen.dart';
import 'package:school_management/main_dashboard.dart';
import 'package:school_management/register_screen.dart';
import 'package:school_management/splash_screen.dart';

import 'onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stawi School Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005A9C), // A professional blue
          primary: const Color(0xFF005A9C),
          secondary: const Color(0xFFE37222), // A warm accent orange
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingPage1(),
        '/login': (context) => const LogInScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const MainDashboardScreen(),
        '/attendance': (context) => const AttendanceManagementScreen(),
      },
    );
  }
}
