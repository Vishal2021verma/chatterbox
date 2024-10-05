import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatterbox/screen/chat_room_screen.dart';
import 'package:chatterbox/screen/users_screen.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              fontSize: 24,
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
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10000),
                          child: CachedNetworkImage(
                            imageUrl: chatterUserData != null
                                ? chatterUserData['photoUrl'] ?? ""
                                : "",
                            errorWidget: (context, url, error) => Container(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (() {
                                      try {
                                        return chatterUserData!['displayName'];
                                      } catch (e) {
                                        return "";
                                      }
                                    }()),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        height: 1.6,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  (() {
                                    try {
                                      DateTime currentDate = DateTime.now();
                                      Timestamp timestamp =
                                          userData['timestamp'];
                                      DateTime dateTime = timestamp.toDate();
                                      String dateString = '';
                                      if (dateTime.day == DateTime.now().day) {
                                        dateString = "Today";
                                      } else if (DateTime(dateTime.year,
                                              dateTime.month, dateTime.day)
                                          .isBefore(DateTime(
                                              currentDate.year,
                                              currentDate.month,
                                              currentDate.day))) {
                                        dateString = 'Yesterday';
                                      } else {
                                        dateString = DateFormat('dd/MM/yy')
                                            .format(dateTime);
                                      }
                                      return dateString;
                                    } catch (e) {
                                      return "";
                                    }
                                  }()),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Text(
                                    (() {
                                      try {
                                        return userData['lastMessage'].isEmpty
                                            ? 'Say Hi to ${chatterUserData!['displayName']}'
                                            : userData['lastMessage'];
                                      } catch (e) {
                                        return "";
                                      }
                                    }()),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),

                                //Add a widget for status and more
                              ],
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
