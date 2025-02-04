import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/lihat/logo_produk.dart';
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
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
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
                    child: IconButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () async {
                        await pickImages();
                      },
                      icon: Icon(
                        listPictures.isEmpty ? Icons.image : Icons.add,
                        size: listPictures.isEmpty ? 150 : 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: ListTile(
                    onTap: () {
                      Get.dialog(KategoriProduk());
                    },
                    title: Text(_productController.kategoriAdd.value)),
              ),
            ),
            ..._productController.listTextField.map((textField) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    vertical: textField['label'] == 'Deskripsi' ? 0 : 4.0,
                    horizontal: 8),
                child: textField['label'] == 'Deskripsi' ||
                        (produkEdit.isEmpty && textField['label'] == 'Terjual')
                    ? null
                    : TextField(
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.top,
                        controller: textField['controller'],
                        keyboardType: textField['keyboardType'],
                        inputFormatters: textField['label'] == 'Nama Produk' ||
                                textField['label'] == 'Deskripsi'
                            ? null
                            : [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'))
                              ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
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
                      ))),
            )
          ],
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
