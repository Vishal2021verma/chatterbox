import 'package:chatterbox/utils/color_resource.dart';
import 'package:chatterbox/utils/image_resource.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        child: MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
          elevation: 0,
          color: ColorResource.primaryColor,
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Agree and Continue",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.06,
              ),
              Image.asset(
                ImageResource.introImage,
                width: MediaQuery.sizeOf(context).width * 0.7,
                height: MediaQuery.sizeOf(context).width * 0.7,
              ),
              const SizedBox(
                height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Welcome To ChatterBox",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 28),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 23,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
