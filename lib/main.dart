import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'log_in_screen.dart'; 
import 'main_dashboard.dart';
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
      title: 'School Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 96, 23, 206),
        ),
        useMaterial3: true,
      ),
      home: const OnboardingPage1(), // start with onboarding
      routes: {
        '/onboarding': (context) => const OnboardingPage1(),
        '/login': (context) => const LogInScreen(),
        '/dashboard': (context) => const MainDashboardScreen(),
        // '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
