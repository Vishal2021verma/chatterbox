import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreService {
  Future<String?> uploadImageToFirebase(File image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    String filename = 'profile_picture/${user.uid}.jpg';

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(filename);
    try {
      await imageRef.putFile(image);
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      // ...
    }
    return null;
  }
}
