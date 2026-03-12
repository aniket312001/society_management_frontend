import 'package:flutter/material.dart';
import 'package:society_management_app/features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Society App',
      home: SplashScreen(),
    );
  }
}
