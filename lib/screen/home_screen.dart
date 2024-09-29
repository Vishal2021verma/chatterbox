import 'dart:convert';
import 'dart:developer';

import 'package:chatterbox/screen/chat_room_screen.dart';
import 'package:chatterbox/screen/users_screen.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  final FireStoreService _fireStoreService = FireStoreService();
  List<DocumentSnapshot> chatters = [];
  User? user;
  @override
  void initState() {
    super.initState();
    user = _authService.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fireStoreService.getAllUserOnChatterBox(
            (bool status, List<DocumentSnapshot> snapshot) {
          if (status) {
            chatters = snapshot;
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Something went wrong!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black87,
            ));
          }
        });
      });
    });
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
      body: StreamBuilder(
          stream: _messageService.getMyChats(user!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              );
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;
            List<Widget> widgetList = docs.map((doc) {
              Map<String, dynamic> userData =
                  doc.data() as Map<String, dynamic>;
              log(userData.toString());

              Map<String, dynamic>? chatterUserData;
              for (var chatUser in chatters) {
                Map<String, dynamic> tempUser =
                    chatUser.data() as Map<String, dynamic>;
                if (userData['otherUserID'] == tempUser['uid']) {
                  log(userData.toString());
                  chatterUserData = tempUser;
                }
              }
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                            userId: userData['otherUserID'],
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
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              (() {
                                try {
                                  return chatterUserData!['displayName'];
                                } catch (e) {
                                  return "";
                                }
                              }()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              (() {
                                try {
                                  return userData['lastMessage'];
                                } catch (e) {
                                  return "";
                                }
                              }()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList();

            return ListView(
              children: widgetList,
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorResource.primaryColor,
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UsersScreen()));
        },
        child: const Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
