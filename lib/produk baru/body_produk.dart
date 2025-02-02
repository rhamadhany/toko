import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/logo_produk.dart';
import 'package:myapp/produk%20baru/edit_deskripsi.dart';
import 'package:myapp/produk%20baru/kategori_produk.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              // KategoriProduk(),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: ListTile(
                    onTap: () {
                      // KategoriProduk();
                      Get.dialog(KategoriProduk());
                    },
                    title: Text(_productController.kategoriTerpilih.value)),
              ),
              ..._productController.listTextField.map((textField) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: textField['label'] == 'Deskripsi' ? 0 : 4.0),
                  child: textField['label'] == 'Deskripsi'
                      ? null
                      : TextField(
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          // expands: textField['label'] == 'Deskripsi' ? true : false,
                          // maxLines: textField['label'] == 'Deskripsi' ? null : 1,
                          controller: textField['controller'],
                          keyboardType: textField['keyboardType'],
                          decoration: InputDecoration(
                              // suffix: textField['label'] != 'Deskripsi'
                              //     ? null
                              //     : Align(alignment: Alignment.centerRight,
                              //       child: IconButton(
                              //           onPressed: () {
                              //             Get.to(() => EditDeskripsi());
                              //           },
                              //           icon: const Icon(Icons.expand)),
                              //     ),
                              labelText: textField['label'],
                              prefixText: textField['label'] == 'Harga Beli' ||
                                      textField['label'] == 'Harga Jual'
                                  ? 'Rp '
                                  : "",
                              border: const OutlineInputBorder()),
                        ),
                );
              }),

              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          Get.to(() => EditDeskripsi());
                        },
                        title: Text(_productController
                                    .listTextField[5]['controller'].text ==
                                ''
                            ? 'Deskripsi...'
                            : _productController
                                .listTextField[5]['controller'].text),
                      )))
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
