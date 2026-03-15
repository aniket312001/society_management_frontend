import 'package:flutter/material.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:society_management_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:society_management_app/features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(CheckLoginUser()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Society App',
        home: SplashScreen(),
      ),
    );
  }
}
