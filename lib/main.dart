import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';
import 'main_navigation.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'explore_screen.dart';
import 'event_detail_screen.dart';
import 'color_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Always show splash first
      routes: {
        '/explore': (context) => const ExploreScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => MainNavigation(),
        '/event_detail': (context) => EventDetailScreen(),
        '/color_detection': (context) => EventThemeDetectorScreen(),
      },
    );
  }
}
