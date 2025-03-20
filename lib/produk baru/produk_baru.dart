import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/produk%20baru/body_produk.dart';
import 'package:myapp/produk%20baru/save_produk.dart';

class NewProduct extends StatelessWidget {
  final ProductController _productController = Get.find();
  NewProduct({
    super.key,
    RxList<dynamic>? listPictures,
    RxMap<String, dynamic>? produkEdit,
    this.refreshGambar,
    // RxList<dynamic>? listPathPictures
  })  : listPictures = listPictures ?? <dynamic>[].obs,
        // listPathPictures = listPathPictures ?? <dynamic>[].obs,
        produkEdit = produkEdit ?? <String, dynamic>{}.obs;

  final RxList<dynamic> listPictures;
  // final RxList<dynamic> listPathPictures;
  final RxMap<String, dynamic> produkEdit;
  final Function? refreshGambar;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                produkEdit.isNotEmpty ? "Edit Produk" : "Produk Baru",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconSave(
                productController: _productController,
                produkEdit: produkEdit,
                listPictures: listPictures,
                refreshGambar: refreshGambar,
              ),
            ],
          ),
        ),
        body: BodyProduk(
          produkEdit: produkEdit,
          listPictures: listPictures,
          // listPathPictures: listPathPictures,
        ),
      );
    });
  }
}
