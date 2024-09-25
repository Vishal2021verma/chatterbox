import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FireStoreService {
  Future<String?> uploadImageToFirebase(XFile image) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    String fileName = image.name;
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('profile_images/$fileName');

    try {
      await imageRef.putFile(
        File(image.path),
      );
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      // ...
      log(e.toString());
    }
    return null;
  }
}
