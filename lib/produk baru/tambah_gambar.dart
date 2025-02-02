import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TambahGambar extends StatelessWidget {
  TambahGambar({super.key, required this.listPictures});
  final RxList<dynamic> listPictures;
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.5,
      height: Get.height * 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () async {
                    final XFile? images =
                        await picker.pickImage(source: ImageSource.camera);
                    if (images != null) {
                      final outputFile = await newPath(images);
                      await File(images.path).copy(outputFile);
                      // print('newPath: $outputFile');
                      listPictures.add(outputFile);
                    }
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.camera,
                    size: 75,
                  )),
              const Text("Kamera")
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () async {
                    final pickedImages = await picker.pickMultiImage();

                    for (final XFile image in pickedImages) {
                      // final imageName = image.path.split('/').last;
                      // final newPath = '$outputDirectory/$imageName';
                      // final outputName = await image.copy(outputDirectory.path);

                      try {
                        final outputFile = await newPath(image);
                        await File(image.path).copy(outputFile);
                        // print('newPath: $outputFile');
                        listPictures.add(outputFile);
                      } catch (e) {
                        // print('Error moving image: $e');
                      }
                    }

                    Get.back();
                  },
                  icon: const Icon(
                    Icons.image,
                    size: 75,
                  )),
              const Text("Galeri")
            ],
          ),
        ],
      ),
    );
  }

  Future<String> newPath(XFile image) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final packageName = packageInfo.packageName;

    final outputDirectory = Directory('/data/user/0/$packageName/images/');

    // Ensure directory exists
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    final ext = image.path.split('.').last;
    final date = DateTime.now();
    final random = Random();

    final newName = '$date${random.nextInt(1000)}.$ext';
    return outputDirectory.path + newName;
  }
}
