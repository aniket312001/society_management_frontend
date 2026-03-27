import 'package:flutter/material.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/core/storage/token_storage.dart';
import 'package:society_management_app/features/auth/presentation/screens/initial_screen.dart';
import 'package:society_management_app/features/user/presentation/screens/user_screen.dart';
import 'package:society_management_app/features/visitors/presentation/screens/visitor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Text("home")),

            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => UserScreen(role: "admin")),
                );
              },
              child: Text("Users"),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VisitorScreen(currentUserId: 5, role: "admin"),
                  ),
                );
              },
              child: Text("VisitorScreen"),
            ),
            ElevatedButton(
              onPressed: () async {
                await sl<TokenStorage>().clearToken();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => InitialScreen()),
                );
              },
              child: Text("logout"),
            ),
          ],
        ),
      ),
    );
  }
}
