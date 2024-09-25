import 'dart:developer';
import 'dart:io';
import 'package:chatterbox/screen/home_screen.dart';
import 'package:chatterbox/service/auth_service.dart';
import 'package:chatterbox/service/fire_store_service.dart';
import 'package:chatterbox/service/image_picker_service.dart';
import 'package:chatterbox/utils/color_resource.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SetProfileScreen extends StatefulWidget {
  const SetProfileScreen({super.key});

  @override
  State<SetProfileScreen> createState() => _SetProfileScreenState();
}

class _SetProfileScreenState extends State<SetProfileScreen> {
  final TextEditingController _nameContorller = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final FireStoreService _fireStoreService = FireStoreService();
  final AuthService _authService = AuthService();
  XFile? _profileImage;

  uploadProfileInfo(String name) async {
    if (_profileImage == null) {
      _authService.updateUserProfileName(name, () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.black87,
            content: Text(
              'Failed to update your profile info. Please try again.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        );
      });
    } else {
      String? photoUrl = await _fireStoreService
          .uploadImageToFirebase(_profileImage!);
      _authService.updateUserProfileInfo(name, photoUrl ?? "", () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.black87,
            content: Text(
              'Failed to update your profile info. Please try again.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Profile Info",
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
            if (_nameContorller.text.length < 3) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text('Please provide valid name'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'))
                      ],
                    );
                  });
            } else {
              uploadProfileInfo(_nameContorller.text.trim());
            }
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 27),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Please provide your name and an optional profile photo",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  builder: (BuildContext context) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 16,
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(1000)),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.grey,
                                  )),
                              const Text(
                                'Profile Photo',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                    onTap: () async {
                                      XFile? image = await _imagePickerService
                                          .getImageFromCamera();
                                      if (image != null) {
                                        _profileImage = image;
                                        setState(() {});
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.camera_alt_outlined,
                                            color: ColorResource.primaryColor,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Camera",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    )),
                                InkWell(
                                    onTap: () async {
                                      XFile? image = await _imagePickerService
                                          .getImageFromGallry();
                                      if (image != null) {
                                        _profileImage = image;
                                        log(_profileImage!.path);
                                        log(_profileImage!.name);
                                        // log(_profileImage.)
                                        setState(() {});
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.photo_album_outlined,
                                            color: ColorResource.primaryColor,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Gallery",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10000),
                child: Container(
                  height: 120,
                  width: 120,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(17, 0, 0, 0),
                      shape: BoxShape.circle),
                  child: _profileImage != null
                      ? Image.file(File(_profileImage!.path))
                      : const Icon(
                          Icons.add_a_photo_rounded,
                          color: Colors.grey,
                          size: 55,
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            TextField(
              controller: _nameContorller,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.name,
              maxLength: 25,
              onChanged: (value) {
                setState(() {});
              },
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                  isCollapsed: true,
                  counterText: "",
                  suffix: Text((25 - _nameContorller.text.length).toString()),
                  contentPadding: EdgeInsets.zero,
                  hintText: "Your Name",
                  hintStyle: const TextStyle(
                    color: Colors.black45,
                  ),
                  focusColor: ColorResource.primaryColor,
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: ColorResource.primaryColor, width: 2)),
                  enabledBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: ColorResource.primaryColor))),
            ),
            // Text(user!.phoneNumber ?? ''),
          ],
        ),
      ),
    );
  }
}
