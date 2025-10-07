import 'package:flutter/material.dart';
import 'log_in_screen.dart'; // if you have a login page

void main() {
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
      home: const LogInScreen(), // or whatever your main page is
    );
  }
}
