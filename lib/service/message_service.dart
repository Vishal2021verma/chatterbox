import 'package:chatterbox/utils/get_chat_room_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  ///Send a message
  Future<void> sendMessage(String messageText, String senderId,
      String otherUserId, String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      "otherUserId": otherUserId,
      "text": messageText,
      "senderId": senderId,
      "timeStamp": FieldValue.serverTimestamp(),
      "isRead": false
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

      updateMyChats(userOneId, userTwoId, "");
    }
  }

  Future<void> updateMyChats(
      String currentUserID, String otherUserID, String lastMessage) async {
    try {
      String chatRoomId =
          GetChatRoomId.getChatRoomId(currentUserID, otherUserID);
      await FirebaseFirestore.instance
          .collection('myChats')
          .doc(currentUserID)
          .collection("chats")
          .doc(chatRoomId)
          .set({
        'chatroomID': chatRoomId,
        'otherUserID': otherUserID,
        'lastMessage': lastMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('myChats')
          .doc(otherUserID)
          .collection('chats')
          .doc(chatRoomId)
          .set({
        'chatroomID': chatRoomId,
        'otherUserID': currentUserID,
        'lastMessage': lastMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  Stream<QuerySnapshot> getMyChats(String currentUserId) {
    return FirebaseFirestore.instance
        .collection("myChats")
        .doc(currentUserId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();

    // callBack(true, docs.data as Map<String, dynamic>);
  }

  ///Update current user typing status
  Future updateTypingStatus(
      String currentUserId, String chatRoomId, bool typingStatus) async {
    await FirebaseFirestore.instance
        .collection("myChats")
        .doc(currentUserId)
        .collection("chats")
        .doc(chatRoomId)
        .collection("typingStatus")
        .doc(currentUserId)
        .set({"isTyping": typingStatus});
  }

  ///Get typing status of user
  Stream<QuerySnapshot> getTypingStatus(String userId, String chatRoomId) {
    return FirebaseFirestore.instance
        .collection("myChats")
        .doc(userId)
        .collection("chats")
        .doc(chatRoomId)
        .collection('typingStatus')
        .snapshots();
  }

  ///Update message's read status
  Future updateMessageReadStatus(String chatRoomId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({"isRead": true});
  }
}
