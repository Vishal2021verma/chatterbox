import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? user = FirebaseAuth.instance.currentUser;

  bool isUserLogedIn() {
    return user != null ? true : false;
  }

  User? getUser() {
    return user;
  }

  updateUserProfileName(String name, successCallbak, failedCallback) {
    user!.updateProfile(displayName: name).then((_) {
      User? user = FirebaseAuth.instance.currentUser;
       successCallbak(user);
    }).catchError((error) {
      failedCallback();
    });
  }

  updateUserProfileImage(String photoUrl, successCallbak, failedCallback) {
    user!.updateProfile(photoURL: photoUrl).then((_) {
      User? user = FirebaseAuth.instance.currentUser;
      successCallbak(user);
    }).catchError((error) {
      failedCallback();
    });
  }

  updateUserProfileInfo(
      String name, String photoUrl, successCallbak, failedCallback) {
    user!.updateProfile(displayName: name, photoURL: photoUrl).then((_) {
      User? user = FirebaseAuth.instance.currentUser;
      successCallbak(user);
    }).catchError((error) {
      failedCallback();
    });
  }
}
