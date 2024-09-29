import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatterbox/screen/chat_room_screen.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FireStoreService _fireStoreService = FireStoreService();
  final AuthService _authService = AuthService();
  User? user;
  List<DocumentSnapshot> chatters = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = _authService.getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoading = true;
      setState(() {});
      _fireStoreService.getAllUserOnChatterBox(
          (bool status, List<DocumentSnapshot> snapshot) {
        if (status) {
          chatters = snapshot;
          isLoading = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select chatter"),
      ),
      body: isLoading
          ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            )
          : ListView.builder(
              itemCount: chatters.length,
              itemBuilder: (context, index) {
                var userData = chatters[index].data() as Map<String, dynamic>;
                return userData['uid'] == user!.uid
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                    userId: userData['uid'],
                                  )));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Row(
                            children: [
                              SizedBox(
                                height: 36,
                                width: 36,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10000),
                                  child: CachedNetworkImage(
                                    imageUrl: userData['photoUrl'] ?? "",
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 18,
                              ),
                              Expanded(
                                  child: Text(
                                userData['displayName'],
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ))
                            ],
                          ),
                        ),
                      );
              }),
    );
  }
}
