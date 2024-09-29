import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:chatterbox/utils/get_chat_room_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      _messageService.updateMyChats(user!.uid, widget.userId, "");
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message['text']),
      ),
    );
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
            SizedBox(
              height: 36,
              width: 36,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000),
                child: CachedNetworkImage(
                  imageUrl:
                      userTwoData != null ? userTwoData!['photoUrl'] ?? "" : "",
                  errorWidget: (context, url, error) => Container(
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
              userTwoData != null ? userTwoData!['displayName'] ?? "" : "",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ))
          ],
        ),
      ),
      body: StreamBuilder(
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
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onEditingComplete: () {
                  if (_messageController.text.isNotEmpty) {
                    _messageService.sendMessage(
                        _messageController.text.trim(), user!.uid, chatRoomId);
                    _messageService.updateMyChats(user!.uid, widget.userId,
                        _messageController.text.trim());
                    _messageController.clear();
                  }
                },
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(hintText: "Type a message"),
              ),
            ),
            const SizedBox(
              width: 18,
            ),
            IconButton(
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _messageService.sendMessage(
                        _messageController.text.trim(), user!.uid, chatRoomId);

                    _messageService.updateMyChats(user!.uid, widget.userId,
                        _messageController.text.trim());
                    _messageController.clear();
                  }
                },
                icon: const Icon(
                  Icons.send_rounded,
                  color: ColorResource.primaryColor,
                ))
          ],
        ),
      ),
    );
  }
}
