import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/logo_produk.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/tambah_gambar.dart';

class NewProduct extends StatelessWidget {
  final ProductController _productController = Get.find();
  NewProduct(
      {super.key,
      RxList<dynamic>? listPictures,
      RxMap<String, dynamic>? produkEdit})
      : listPictures = listPictures ?? <dynamic>[].obs,
        produkEdit = produkEdit ?? <String, dynamic>{}.obs;

  final RxList<dynamic> listPictures;
  final RxMap<String, dynamic> produkEdit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            produkEdit.isNotEmpty ? "Edit Produk" : "Produk Baru",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String product =
                _productController.listTextField[0]['controller'].text;
            String hargaBeli =
                _productController.listTextField[1]['controller'].text;
            String hargaJual =
                _productController.listTextField[2]['controller'].text;
            int? terjual = int.tryParse(
                    _productController.listTextField[3]['controller'].text) ??
                0;
            int? stock = int.tryParse(
                    _productController.listTextField[4]['controller'].text) ??
                0;

            if (produkEdit.isNotEmpty) {
              produkEdit['gambar'] = listPictures;
              produkEdit['produk'] = product;
              produkEdit['harga_beli'] = hargaBeli;
              produkEdit['harga_jual'] = hargaJual;
              produkEdit['terjual'] = terjual;
              produkEdit['stok'] = stock;

              await DBHelper.updateProduct(produkEdit);
            } else {
              await DBHelper.addProduct(
                  product, hargaBeli, hargaJual, terjual, stock, listPictures);
            }

            Get.back();
          },
          child: const Icon(Icons.check),
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
