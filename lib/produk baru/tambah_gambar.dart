import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/manager/drawer_admin.dart';

class TambahGambar extends StatelessWidget {
  TambahGambar({
    super.key,
    required this.resultTap,
    required this.singleImage,
    this.hapusGambar,
  });

  final ImagePicker picker = ImagePicker();
  final Function(String) resultTap;
  final Function? hapusGambar;
  final bool singleImage;
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (singleImage)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      hapusGambar!();
                    },
                    icon: Icon(
                      Icons.people,
                      size: 75,
                    ),
                  ),
                  const Text("Hapus")
                ],
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () async {
                      final XFile? images =
                          await picker.pickImage(source: ImageSource.camera);
                      if (images != null) {
                        await resultTap(images.path);
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
                      if (singleImage) {
                        final pickedImages =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedImages != null) {
                          await resultTap(pickedImages.path);
                        }
                      } else {
                        final pickedImages = await picker.pickMultiImage();
                        for (final XFile image in pickedImages) {
                          await resultTap(image.path);
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
      ),
    );
  }
}
