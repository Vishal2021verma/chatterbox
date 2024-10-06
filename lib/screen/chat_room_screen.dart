import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:chatterbox/service/notification_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:chatterbox/utils/get_chat_room_id.dart';
import 'package:chatterbox/utils/image_resource.dart';
import 'package:chatterbox/utils/messsage_iteam_widget.dart';
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

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  final FireStoreService _fireStoreService = FireStoreService();
  final NotificationServices _notificationServices = NotificationServices();
  User? user;
  String chatRoomId = '';
  Map<String, dynamic>? userTwoData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user = _authService.user;
    chatRoomId = GetChatRoomId.getChatRoomId(user!.uid, widget.userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fireStoreService.updateUserStatus(user!.uid, true);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fireStoreService.updateUserStatus(user!.uid, true);
    } else {
      _fireStoreService.updateUserStatus(user!.uid, false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageService.updateTypingStatus(user!.uid, chatRoomId, false);
    _fireStoreService.updateUserStatus(user!.uid, false);
    WidgetsBinding.instance.removeObserver(this);
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
                // return _buildMessageItem(doc.data() as Map<String, dynamic>);
                Map<String, dynamic> message =
                    doc.data() as Map<String, dynamic>;
                return MesssageIteamWidget(
                  message: message,
                  messageId: doc.id,
                  chatRoomId: chatRoomId,
                  isMe: message['senderId'] == user!.uid,
                );
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
                // onEditingComplete: () {
                //   if (_messageController.text.isNotEmpty) {
                //     _messageService.sendMessage(_messageController.text.trim(),
                //         user!.uid, userTwoData!["uid"], chatRoomId);
                //     _messageService.updateMyChats(user!.uid, widget.userId,
                //         _messageController.text.trim());

                //     _messageController.clear();
                //     _messageService.updateTypingStatus(
                //         user!.uid, chatRoomId, false);
                //   }
                // },
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
                      onTap: () async {
                        if (_messageController.text.isNotEmpty) {
                          //Send the message
                          _messageService.sendMessage(
                              _messageController.text.trim(),
                              user!.uid,
                              userTwoData!["uid"],
                              chatRoomId);

                          //Update the mychats
                          _messageService.updateMyChats(user!.uid,
                              widget.userId, _messageController.text.trim());
                          String messageText = _messageController.text.trim();

                          //Clear the text field after sending ther message
                          _messageController.clear();

                          //Update the typing status
                          _messageService.updateTypingStatus(
                              user!.uid, chatRoomId, false);
                          bool otherUserStatus = await _fireStoreService
                              .getUserStatus(userTwoData!['uid']);

                          if (!otherUserStatus) {
                            _notificationServices.sendNotification(
                                userTwoData!['fcmToken'] ?? '',
                                messageText,
                                user!.uid,
                                userTwoData!["uid"],
                                chatRoomId);
                          }
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
