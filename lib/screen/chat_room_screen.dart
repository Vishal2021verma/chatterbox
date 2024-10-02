import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:chatterbox/utils/get_chat_room_id.dart';
import 'package:chatterbox/utils/image_resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  const ChatRoomScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  final FireStoreService _fireStoreService = FireStoreService();
  User? user;
  String chatRoomId = '';
  Map<String, dynamic>? userTwoData;

  @override
  void initState() {
    super.initState();
    user = _authService.user;
    chatRoomId = GetChatRoomId.getChatRoomId(user!.uid, widget.userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _messageService.updateMyChats(user!.uid, widget.userId, "");
      _fireStoreService.getUserOnChatterBox(widget.userId,
          (bool status, Map<String, dynamic>? data) {
        if (status) {
          userTwoData = data;
          setState(() {});
        }
      });
      _messageService.createChatRoomIfNotExit(user!.uid, widget.userId);
    });
  }

  /// Builds each message item
  Widget _buildMessageItem(Map<String, dynamic> message) {
    bool isMe = message['senderId'] == user!.uid;
    return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: isMe
            ? Container(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 4, right: 14, left: 14),
                margin: const EdgeInsets.only(bottom: 5, right: 16, left: 60),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xffe9f8df) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message['text'],
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      (() {
                        try {
                          Timestamp timestamp = message['timeStamp'];
                          DateTime dateTime = timestamp.toDate();
                          String dateString = '';
                          dateString = DateFormat('h:m a').format(dateTime);
                          return dateString;
                        } catch (e) {
                          return "";
                        }
                      }()),
                      style:
                          const TextStyle(color: Colors.black45, fontSize: 10),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 4, right: 14, left: 14),
                margin: const EdgeInsets.only(bottom: 5, right: 60, left: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['text'],
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      (() {
                        try {
                          Timestamp timestamp = message['timeStamp'];
                          DateTime dateTime = timestamp.toDate();
                          String dateString = '';
                          dateString = DateFormat('h:m a').format(dateTime);
                          return dateString;
                        } catch (e) {
                          return "";
                        }
                      }()),
                      style:
                          const TextStyle(color: Colors.black45, fontSize: 10),
                    ),
                  ],
                ),
              ));
  }

  @override
  void dispose() {
    super.dispose();
    _messageService.updateTypingStatus(user!.uid, chatRoomId, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      appBar: AppBar(
        backgroundColor: ColorResource.primaryColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(1000),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    SizedBox(
                      height: 36,
                      width: 36,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10000),
                        child: CachedNetworkImage(
                          imageUrl: userTwoData != null
                              ? userTwoData!['photoUrl'] ?? ""
                              : "",
                          errorWidget: (context, url, error) => Container(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userTwoData != null
                        ? userTwoData!['displayName'] ?? ""
                        : "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  StreamBuilder(
                      stream: _messageService.getTypingStatus(
                          userTwoData != null ? userTwoData!['uid'] : "12345",
                          chatRoomId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasData) {
                          List<DocumentSnapshot> data = snapshot.data!.docs;
                          List<Widget> typinStatusWidget = data.map((doc) {
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            return !data["isTyping"]
                                ? const SizedBox.shrink()
                                : const Text('typing...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ));
                          }).toList();
                          return typinStatusWidget.isNotEmpty
                              ? typinStatusWidget.first
                              : const SizedBox.shrink();
                        } else {
                          return const SizedBox.shrink();
                        }
                      })
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  ImageResource.chatBgImage,
                ),
                fit: BoxFit.cover)),
        child: StreamBuilder(
            stream: _messageService.getMessages(chatRoomId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              List<DocumentSnapshot> docs = snapshot.data!.docs;
              List<Widget> messages = docs.map((doc) {
                return _buildMessageItem(doc.data() as Map<String, dynamic>);
              }).toList();

              return ListView(
                reverse: true,
                children: messages,
              );
            }),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(ImageResource.chatBgImage),
                fit: BoxFit.cover)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.newline,
                onEditingComplete: () {
                  if (_messageController.text.isNotEmpty) {
                    _messageService.sendMessage(
                        _messageController.text.trim(), user!.uid, chatRoomId);
                    _messageService.updateMyChats(user!.uid, widget.userId,
                        _messageController.text.trim());

                    _messageController.clear();
                    _messageService.updateTypingStatus(
                        user!.uid, chatRoomId, false);
                  }
                },
                onChanged: (value) {
                  //Update typing status
                  _messageService.updateTypingStatus(
                      user!.uid, chatRoomId, value.isEmpty ? false : true);
                },
                minLines: 1,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                      borderSide: BorderSide.none, // No visible border
                    ),
                    hintText: "Message",
                    hintStyle: const TextStyle(color: Colors.black54)),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: SizedBox(
                height: 48,
                width: 48,
                child: Container(
                  color: ColorResource.primaryColor,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_messageController.text.isNotEmpty) {
                          _messageService.sendMessage(
                              _messageController.text.trim(),
                              user!.uid,
                              chatRoomId);
                          _messageService.updateMyChats(user!.uid,
                              widget.userId, _messageController.text.trim());
                          _messageController.clear();
                          _messageService.updateTypingStatus(
                              user!.uid, chatRoomId, false);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
