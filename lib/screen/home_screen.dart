import 'package:chatterbox/service/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10000),
              child: Image.network(
                _authService.user!.photoURL ?? "",
                width: 60,
                height: 60,
              ),
            ),
            Text(
              "Welcome ${_authService.user!.displayName ?? ""}",
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}

