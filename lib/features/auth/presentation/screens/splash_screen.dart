// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';
import 'package:society_management_app/features/society/screens/society_status_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'initial_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated ||
            (state is SocietyStatusState &&
                state.society?.status == "approved")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is SocietyStatusState &&
            state.society != null &&
            state.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SocietyStatusScreen(
                user: state.user!,
                society: state.society,
                errorMessage: state.error,
              ),
            ),
          );
        } else if (state is UnAuthenticated || state is AuthError) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InitialScreen()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apartment, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Society Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
