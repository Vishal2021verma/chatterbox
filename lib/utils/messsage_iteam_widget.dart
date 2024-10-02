import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MesssageIteamWidget extends StatefulWidget {
  final Map<String, dynamic> message;
  final String messageId;
  final String chatRoomId;
  final bool isMe;
  const MesssageIteamWidget(
      {super.key,
      required this.message,
      required this.messageId,
      required this.chatRoomId,
      required this.isMe});

  @override
  State<MesssageIteamWidget> createState() => _MesssageIteamWidgetState();
}

class _MesssageIteamWidgetState extends State<MesssageIteamWidget> {
  final AuthService _authService = AuthService();

  User? user;

  @override
  void initState() {
    super.initState();
    user = _authService.user;

    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      !widget.isMe
          ? widget.message['isRead'] != null && !widget.message['isRead']
              ? MessageService()
                  .updateMessageReadStatus(widget.chatRoomId, widget.messageId)
              : null
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: widget.isMe
            ? Container(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 4, right: 14, left: 14),
                margin: const EdgeInsets.only(bottom: 5, right: 16, left: 60),
                decoration: BoxDecoration(
                  color: widget.isMe ? const Color(0xffe9f8df) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.message['text'],
                      textAlign: TextAlign.start,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (() {
                            try {
                              Timestamp timestamp = widget.message['timeStamp'];
                              DateTime dateTime = timestamp.toDate();
                              String dateString = '';
                              dateString = DateFormat('h:m a').format(dateTime);
                              return dateString;
                            } catch (e) {
                              return "";
                            }
                          }()),
                          style: const TextStyle(
                              color: Colors.black45, fontSize: 11),
                        ),
                        widget.message['isRead'] != null
                            ? widget.message['isRead']
                                ? const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.done_all_rounded,
                                      color: Colors.blue,
                                      size: 14,
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.done_rounded,
                                      color: Colors.grey,
                                      size: 14,
                                    ),
                                  )
                            : const SizedBox.shrink()
                      ],
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
                      widget.message['text'],
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      (() {
                        try {
                          Timestamp timestamp = widget.message['timeStamp'];
                          DateTime dateTime = timestamp.toDate();
                          String dateString = '';
                          dateString = DateFormat('h:m a').format(dateTime);
                          return dateString;
                        } catch (e) {
                          return "";
                        }
                      }()),
                      style:
                          const TextStyle(color: Colors.black45, fontSize: 11),
                    ),
                  ],
                ),
              ));
  }
}
