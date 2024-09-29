class GetChatRoomId {
  static String getChatRoomId(String userOneId, String userTwoId) {
    if (userOneId.compareTo(userTwoId) < 0) {
      return "${userOneId}_$userTwoId";
    } else {
      return "${userTwoId}_$userOneId";
    }
  }
}
