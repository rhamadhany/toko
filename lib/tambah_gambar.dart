import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
                      listPictures.add(images.path);
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
                    List<XFile> images = await picker.pickMultiImage();

                    for (var img in images) {
                      final path = img.path;
                      listPictures.add(path);
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
}
