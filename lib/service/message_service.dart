import 'package:chatterbox/utils/get_chat_room_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  ///Send a message
  Future<void> sendMessage(
      String messageText, String senderId, String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      "text": messageText,
      "senderId": senderId,
      "timeStamp": FieldValue.serverTimestamp()
    });
  }

  ///Retrive messages in real-time.
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  ///Creates a chatroom if chatroom is not exits on cloud firestore.
  Future<void> createChatRoomIfNotExit(
    String userOneId,
    String userTwoId,
  ) async {
    String chatRoomId = GetChatRoomId.getChatRoomId(userOneId, userTwoId);

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .get();

    if (!documentSnapshot.exists) {
      await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
        "users": [userOneId, userTwoId],
        "lastMessage": "",
        "timeStamp": FieldValue.serverTimestamp()
      });
    }
  }
}
