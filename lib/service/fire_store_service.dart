import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  ///Saves user data on Cloud Firebase Firestore data
  Future saveUserOnCloud(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      "displayName": user.displayName ?? "",
      "uid": user.uid,
      "photoUrl": user.photoURL ?? "",
      "phoneNumber": user.phoneNumber ?? ""
    });
  }

  Future getAllUserOnChatterBox(callBack) async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      callBack(true, usersSnapshot.docs);
    } catch (e) {
      callBack(false, null);

    }
  }
  Future getUserOnChatterBox(String uid, callBack) async {
    try {
     DocumentSnapshot userDoc = 
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      callBack(true, userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      callBack(false, null);

    }
  }
}
