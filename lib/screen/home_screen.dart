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
    return  Scaffold(
      body: Center(
        child: Text(
          "Welcome ${_authService.user!.displayName ?? ""}",
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
