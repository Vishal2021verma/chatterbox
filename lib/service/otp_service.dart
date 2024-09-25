import 'dart:developer';
import 'package:chatterbox/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId;
  int? _resendToken; // Store the resend token

  Future<void> sendOtp(
      String value, Function(String, int?) codeSent, failedCallback) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: "+91$value",
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs in the user when verification is complete
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          failedCallback();
          showDialog(
              context: navigatorKey.currentState!.context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Verification Failed"),
                  content: const Text(
                    'Provided phone number failed to verify.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(navigatorKey.currentState!.context)
                              .pop();
                        },
                        child: const Text('OK'))
                  ],
                );
              });
        },
        codeSent: (String verificatrionId, int? resendToken) {
          codeSent(verificatrionId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout callback
        });
  }

  Future<void> resendOtp(
      String value, int resendCode, Function(String, int?) codeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$value",
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically signs in the user when verification is complete
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        showDialog(
            context: navigatorKey.currentState!.context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Verification Failed"),
                content: const Text(
                  'Provided phone number failed to verify. Please provide correct phone number.',
                  style: TextStyle(color: Colors.black54),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(navigatorKey.currentState!.context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      },
      codeSent: (String verificatrionId, int? resendToken) {
        codeSent(verificatrionId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto retrieval timeout callback
      },
      forceResendingToken: resendCode,
    );
  }

  Future<void> verifyOTP(String verificationId, String otpCode, successCallback,
      errorCallback) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    // Sign in the user with the credential
    try {
      await auth.signInWithCredential(credential);
      log('User signed in successfully');
      successCallback();
    } catch (e) {
      errorCallback();
    }
  }
}
