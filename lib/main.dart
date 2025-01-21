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
          title: Row(
            children: [
              const Text(
                "Toko",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    _productController.showSearch.value =
                        !_productController.showSearch.value;

                    if (!_productController.showSearch.value) {
                      _productController.searchText.value = '';
                    }
                  },
                  icon: const Icon(Icons.search))
            ],
          ),
        ),
        body:

            // _productController.filterProduct.isEmpty
            //     ? const Center(
            //         child: Text(
            //         "Tidak ada produk",
            //         style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            //       ))
            //     :
            HomeToko(productController: _productController),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_productController.showCheckBoxRemove.value &&
                _productController.filterProduct.isNotEmpty) {
              List<String> listKey = [];
              for (int i = 0;
                  i < _productController.filterProduct.length;
                  i++) {
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
                  _productController.filterProduct.isNotEmpty
              ? Icons.clear
              : Icons.add),
        ),
      );
    });
  }
}
