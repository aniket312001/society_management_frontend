// features/auth/presentation/screens/society_status_screen.dart
import 'package:flutter/material.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:society_management_app/features/society/screens/home_screen.dart';

class SocietyStatusScreen extends StatelessWidget {
  final UserEntity user;
  final SocietyEntity? society;
  final String? errorMessage;

  const SocietyStatusScreen({
    super.key,
    required this.user,
    this.society,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String title;
    String message;
    IconData icon;
    Color iconColor;
    Widget? actionButton;

    if (errorMessage != null) {
      title = 'Something Went Wrong';
      message = errorMessage!;
      icon = Icons.error_outline_rounded;
      iconColor = Colors.red;
    } else if (society == null) {
      title = 'No Society Found';
      message =
          'You are not associated with any society yet.\nPlease create or join one.';
      icon = Icons.apartment_outlined;
      iconColor = Colors.grey;
      actionButton = ElevatedButton.icon(
        onPressed: () {
          // Go back to registration or initial screen
          Navigator.pushReplacementNamed(context, '/register');
        },
        icon: const Icon(Icons.add_business),
        label: const Text('Create Society'),
      );
    } else {
      final status = society!.status.toLowerCase();

      if (status == 'active' || status == 'approved') {
        // If active → go directly to home (no need to show status screen)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        });
        return const SizedBox.shrink(); // temporary empty
      } else if (status == 'pending') {
        title = 'Registration Pending';
        message =
            'Your society "${society!.name}" is under review.\n'
            'We will notify you once it is approved.';
        icon = Icons.hourglass_empty_rounded;
        iconColor = Colors.orange;
      } else if (status == 'rejected') {
        title = 'Registration Rejected';
        message =
            'Your society "${society!.name}" was not approved.\n'
            '${society!.description.isNotEmpty ? "Reason: ${society!.description}" : "No reason provided."}';
        icon = Icons.cancel_rounded;
        iconColor = Colors.red;
        actionButton = Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Create New Society'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Logout or contact support
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support'),
            ),
          ],
        );
      } else {
        title = 'Unknown Status';
        message = 'Society status: ${society!.status}\nPlease contact support.';
        icon = Icons.help_outline_rounded;
        iconColor = Colors.blueGrey;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 90, color: iconColor),
              const SizedBox(height: 32),
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (actionButton != null) actionButton,
              const Spacer(),
              Text(
                'User: ${user.name} • ${user.email}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
