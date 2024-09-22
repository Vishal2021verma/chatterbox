import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? user = FirebaseAuth.instance.currentUser;

  bool isUserLogedIn() {
    return user != null ? true : false;
  }

  User? getUser() {
    return user;
  }
}
