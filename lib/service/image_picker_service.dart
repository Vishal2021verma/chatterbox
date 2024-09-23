import 'package:chatterbox/main.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> getImageFromGallry() async {
    try {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        CroppedFile? cropedImage = await cropImage(image);
        if (cropedImage != null) {
          return XFile(cropedImage.path);
        }
      }
    } catch (e) {
      showDialog(
          context: navigatorKey.currentState!.context,
          builder: (context) {
            return AlertDialog(
              content: const Text('An error occurred while picking the image.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
    return null;
  }

  Future<XFile?> getImageFromCamera() async {
    try {
      XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        CroppedFile? cropedImage = await cropImage(image);
        if (cropedImage != null) {
          return XFile(cropedImage.path);
        }
      }
    } catch (e) {
      showDialog(
          context: navigatorKey.currentState!.context,
          builder: (context) {
            return AlertDialog(
              content: const Text('An error occurred while picking the image.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'))
              ],
            );
          });
    }
    return null;
  }

  Future<CroppedFile?> cropImage(XFile imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          cropStyle: CropStyle.circle,
          toolbarColor: Colors.black,
          toolbarTitle: "",
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            // CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
      ],
    );
    return croppedFile;
  }
}

class CropAspectRatioPresetCustom {}
