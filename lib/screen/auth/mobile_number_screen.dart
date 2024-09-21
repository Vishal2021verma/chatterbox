import 'package:chatterbox/screen/auth/verify_number_screen.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> sendOtp(Function(String) codeSent) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
        phoneNumber: "+91${_controller.text}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs in the user when verification is complete
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificatrionId, int? resendToken) {
          codeSent(verificatrionId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout callback
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Enter your phone number",
          style: TextStyle(
              color: ColorResource.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        child: MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
          elevation: 0,
          color: ColorResource.primaryColor,
          onPressed: () {
            sendOtp((String verifiactionID) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => VerifyNumberScreen(
                        mobileNumber: _controller.text,
                        verificationId: verifiactionID,
                      )));
            });
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ChatterBox will need to verify your phone number.",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(RegExp(r'^[6-9]\d{0,9}$')),
                ],
                onSubmitted: (value) {
                  sendOtp((String verifiactionID) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => VerifyNumberScreen(
                              mobileNumber: _controller.text,
                              verificationId: verifiactionID,
                            )));
                  });
                },
                decoration: const InputDecoration(
                    isCollapsed: true,
                    hintText: "Phone number",
                    hintStyle: TextStyle(
                      color: Colors.black45,
                    ),
                    focusColor: ColorResource.primaryColor,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorResource.primaryColor, width: 2)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: ColorResource.primaryColor))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
