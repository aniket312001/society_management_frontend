import 'package:flutter/material.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/core/storage/token_storage.dart';

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
                await sl<TokenStorage>().clearToken();
              },
              child: Text("logout"),
            ),
          ],
        ),
      ),
    );
  }
}
