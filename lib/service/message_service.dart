import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  ///Send a message
  Future<void> sendMessage(String messageText, String senderId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc('chatRoomId')
        .collection('messages')
        .add({
      "text": messageText,
      "senderId": senderId,
      "timeStamp": FieldValue.serverTimestamp()
    });
  }

  ///Retrive messages in real-time
  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc('chatRoomId')
        .collection('messages')
        .orderBy('timeStamp')
        .snapshots();
  }
}
