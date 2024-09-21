import 'package:chatterbox/screen/auth/mobile_number_screen.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class VerifyNumberScreen extends StatefulWidget {
  final String mobileNumber;
  const VerifyNumberScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Verifying your number",
          style: TextStyle(
              color: ColorResource.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'We have sent an SMS with a code to ',
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                    children: <TextSpan>[
                      TextSpan(
                        text: "${widget.mobileNumber}.",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const MobileNumberScreen()));
              },
              child: const Text(
                'Wrong Number?',
                style: TextStyle(
                  height: 2,
                  color: Color.fromARGB(255, 66, 158, 204),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            OtpTextField(
              cursorColor: ColorResource.primaryColor,
              numberOfFields: 6,

              borderColor: Color(0xFF512DA8),
              //set to true to show as box or false to show as dash
              showFieldAsBox: false,
              //runs when a code is typed in
              onCodeChanged: (String code) {
                //handle validation or checks here
              },
              focusedBorderColor: ColorResource.primaryColor,
              //runs when every textfield is filled
              onSubmit: (String verificationCode) {
                // showDialog(
                //     context: context,
                //     builder: (context) {
                //       return AlertDialog(
                //         title: Text("Verification Code"),
                //         content: Text('Code entered is $verificationCode'),
                //       );
                //     });
              }, // end onSubmit
            ),
            const SizedBox(
              height: 60,
            ),
            const Text(
              'Enter 6 digit code',
              style: TextStyle(
                height: 2,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const MobileNumberScreen()));
              },
              child: const Text(
                "Didn't receive code?",
                style: TextStyle(
                  height: 2,
                  color: ColorResource.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
