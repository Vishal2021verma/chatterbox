import 'dart:async';
import 'package:chatterbox/provider/loading_provider.dart';
import 'package:chatterbox/screen/auth/mobile_number_screen.dart';
import 'package:chatterbox/screen/set_profile_screen.dart';
import 'package:chatterbox/service/otp_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class VerifyNumberScreen extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;
  final int? resendToken;
  const VerifyNumberScreen({
    super.key,
    required this.mobileNumber,
    required this.verificationId,
    required this.resendToken,
  });

  @override
  State<VerifyNumberScreen> createState() => _VerifyNumberScreenState();
}

class _VerifyNumberScreenState extends State<VerifyNumberScreen> {
  Timer? _timer;
  int _remainingTime = 60;
  int attempts = 1;
  OtpService _otpService = OtpService();
  bool clearText = false;

  startTimer() {
    if (attempts < 3) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime--;
          });
        } else {
          _timer!.cancel();
          setState(() {});
        }
      });
      attempts = attempts + 1;
      setState(() {});
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              // title: Text("Verification Code"),
              content: const Text(
                  'You have reached the maximum limit for resending OTPs. Please wait for some time before trying again'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MobileNumberScreen()));
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
  }

  resartTimer() {
    _timer!.cancel();
    setState(() {
      _remainingTime = 60;
    });
    startTimer();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

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
              borderColor: const Color(0xFF512DA8),
              showFieldAsBox: false,
              clearText: clearText,
              onCodeChanged: (String code) {
                clearText = false;
                setState(() {});
              },
              focusedBorderColor: ColorResource.primaryColor,
              onSubmit: (String code) {
                Provider.of<LoadingProvider>(context, listen: false).isLoading =
                    true;
                _otpService.verifyOTP(widget.verificationId, code, () {
                  Provider.of<LoadingProvider>(context, listen: false)
                      .isLoading = false;

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const SetProfileScreen()));
                }, () {
                  Provider.of<LoadingProvider>(context, listen: false)
                      .isLoading = false;

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Verification Failed"),
                          content: const Text(
                            'Incorrect OTP entered. Please try again.',
                            style: TextStyle(color: Colors.black54),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  clearText = true;
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'))
                          ],
                        );
                      });
                });
              },
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
              height: 16,
            ),
            (attempts == 3 && _remainingTime == 0)
                ? InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MobileNumberScreen()));
                    },
                    child: const Text(
                      "Try again!",
                      style: TextStyle(
                        height: 2,
                        color: ColorResource.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: _remainingTime == 0
                        ? () {
                            _otpService.resendOtp(
                                widget.mobileNumber, widget.resendToken ?? 0,
                                (String verifiactionID, int? resendToken) {
                              resartTimer();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.black87,
                                  content: Text(
                                    'Otp send successfully.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              );
                            });
                          }
                        : null,
                    child: Text(
                      (_remainingTime != 0)
                          ? '$_remainingTime seconds'
                          : "Didn't receive code?",
                      style: const TextStyle(
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
