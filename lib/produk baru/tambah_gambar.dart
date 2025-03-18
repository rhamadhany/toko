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
    return IntrinsicHeight(
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
                      try {
                        // final outputFile = await newPath(image);
                        // await File(image.path).copy(outputFile);

                        listPictures.add(image.path);
                      } catch (e) {
                        //
                        debugPrint('error $e');
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
