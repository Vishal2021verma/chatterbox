import 'package:chatterbox/screen/home_screen.dart';
import 'package:chatterbox/screen/intro_screen.dart';
import 'package:chatterbox/screen/set_profile_screen.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  navigate() {
    if (_authService.isUserLogedIn() &&
        _authService.getUser()!.displayName == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SetProfileScreen()));
    } else if (_authService.isUserLogedIn() &&
        _authService.getUser()!.displayName != null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (!_authService.isUserLogedIn()) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "ChatterBox",
          style: TextStyle(
              color: ColorResource.primaryColor,
              fontSize: 40,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
