import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/beranda_toko.dart';
import 'package:myapp/produk_baru.dart';
import 'package:myapp/product_controller.dart';

void main() {
  runApp(GetMaterialApp(
    home: MyApp(),
    theme: ThemeData(),
    darkTheme: ThemeData.dark(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ProductController _productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Toko",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: _productController.loadingProduct.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _productController.allProduct.isEmpty
                ? const Center(
                    child: Text(
                    "Tidak ada produk",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ))
                : HomeToko(productController: _productController),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_productController.showCheckBoxRemove.value &&
                _productController.allProduct.isNotEmpty) {
              List<String> listKey = [];
              for (int i = 0; i < _productController.allProduct.length; i++) {
                if (_productController.mapCheckBoxRemove[i]['isSelected'] ==
                        'true' &&
                    _productController.mapCheckBoxRemove[i]['key'] != "") {
                  listKey.add(_productController.mapCheckBoxRemove[i]['key']!);
                }
              }

              await _productController.deleteProduct(listKey);
              await _productController.generateMapCheckBox();
            } else {
              for (final controller in _productController.listTextField) {
                if (controller['label'] != 'Terjual') {
                  controller['controller'].clear();
                } else {
                  controller['controller'].text = "0";
                }
              }

              Get.to(() => NewProduct());
            }
          },
          child: Icon(_productController.showCheckBoxRemove.value &&
                  _productController.allProduct.isNotEmpty
              ? Icons.clear
              : Icons.add),
        ),
      );
    });
  }
}
