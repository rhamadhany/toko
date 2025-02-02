import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/logo_produk.dart';
import 'package:myapp/produk%20baru/tambah_gambar.dart';

class BodyProduk extends StatelessWidget {
  BodyProduk({required this.produkEdit, required this.listPictures, super.key});

  final ProductController _productController = Get.find();
  final RxMap<String, dynamic> produkEdit;
  final RxList listPictures;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...listPictures.map((imageFile) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Stack(
                          children: [
                            logoProduk(imageFile, 10, 120, 2),
                            Positioned(
                                right: -22,
                                top: -10,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: const CircleBorder(),
                                      minimumSize: const Size(20, 20),
                                    ),
                                    onPressed: () {
                                      listPictures.remove(imageFile);
                                    },
                                    child: const Icon(
                                      Icons.clear,
                                      color: Colors.white,
                                      size: 25,
                                    )))
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                        ),
                        onPressed: () async {
                          await pickImages();
                        },
                        child: Icon(
                          Icons.add,
                          size: listPictures.isEmpty ? 50 : 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._productController.listTextField.map((textField) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextField(
                    controller: textField['controller'],
                    keyboardType:
                        textField['keyboardType'] ?? TextInputType.text,
                    decoration: InputDecoration(
                        labelText: textField['label'],
                        prefixText: textField['label'] == 'Harga Beli' ||
                                textField['label'] == 'Harga Jual'
                            ? 'Rp '
                            : "",
                        border: const OutlineInputBorder()),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Future<void> pickImages() async {
    Get.dialog(AlertDialog(
        content: TambahGambar(
      listPictures: listPictures,
    )));
  }
}
