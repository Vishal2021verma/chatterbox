import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String name;
  const ChatRoomScreen(
      {super.key, required this.chatRoomId, required this.name});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  User? user;
  @override
  void initState() {
    super.initState();
    user = _authService.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageService.createChatRoomIfNotExit(
          'l5hGNJ4NE5QuJwwtfxlWXzXIK0B3', 'qMgAftUeGgXJjF1NJJtvz2GPUcr1');
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
        title: Row(
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(10000),
            //   child: Image.network(
            //     _authService.user!.photoURL ?? "",
            //     width: 36,
            //     height: 36,
            //   ),
            // ),
            // const SizedBox(
            //   width: 16,
            // ),
            Text(
              widget.name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: _messageService.getMessages(widget.chatRoomId),
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
                    _messageService.sendMessage(_messageController.text.trim(),
                        user!.uid, widget.chatRoomId);
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
                    _messageService.sendMessage(_messageController.text.trim(),
                        user!.uid, widget.chatRoomId);
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
