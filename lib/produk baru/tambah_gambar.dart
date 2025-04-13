import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controller/product_controller.dart';

class TambahGambar extends GetView<ProductController> {
  const TambahGambar({
    super.key,
    required this.resultTap,
    required this.singleImage,
    this.hapusGambar,
    this.image,
  });

  // final ImagePicker picker = ImagePicker();
  final Function(String) resultTap;
  final Function? hapusGambar;
  final bool singleImage;
  final Uint8List? image;
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (singleImage && image != null)
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
                    size: 50,
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
                    final XFile? images = await controller.imagePicker
                        .pickImage(source: ImageSource.camera);
                    if (images != null) {
                      await resultTap(images.path);
                    }
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.camera,
                    size: 50,
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
                      final pickedImages = await controller.imagePicker
                          .pickImage(source: ImageSource.gallery);
                      if (pickedImages != null) {
                        await resultTap(pickedImages.path);
                      }
                    } else {
                      final pickedImages =
                          await controller.imagePicker.pickMultiImage();

                      for (final XFile image in pickedImages) {
                        await resultTap(image.path);
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.image,
                    size: 50,
                  )),
              const Text("Galeri")
            ],
          ),
        ],
      ),
    );
  }
}
