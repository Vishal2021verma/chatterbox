import 'package:chatterbox/screen/chat_room_screen.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthService _authService = AuthService();
  User? user;
  @override
  void initState() {
    super.initState();
    user = _authService.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "ChatterBox",
          style: TextStyle(
              color: ColorResource.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                          chatRoomId:
                              'l5hGNJ4NE5QuJwwtfxlWXzXIK0B3_qMgAftUeGgXJjF1NJJtvz2GPUcr1',
                          name: user!.displayName
                                  .toString()
                                  .toLowerCase()
                                  .contains("vishal")
                              ? "Anurag Verma"
                              : "Vishal Verma",
                        )));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(115, 96, 125, 139)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      user!.displayName
                              .toString()
                              .toLowerCase()
                              .contains("vishal")
                          ? "Anurag Verma"
                          : "Vishal Verma",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
