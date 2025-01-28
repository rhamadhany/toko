import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/lihat_produk.dart';
import 'package:myapp/logo_produk.dart';
import 'package:myapp/product_controller.dart';

class HomeToko extends StatelessWidget {
  const HomeToko({
    super.key,
    required ProductController productController,
  }) : _productController = productController;

  final ProductController _productController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_productController.showCheckBoxRemove.value) {
            _productController.showCheckBoxRemove.value = false;
          } else {
            Get.dialog(
              barrierDismissible: false,
              AlertDialog(
                title: const Text("Keluar"),
                content: const Text("Keluar dari aplikasi?"),
                actions: [
                  ElevatedButton(
                      onPressed: () => Get.back(), child: const Text("Tidak")),
                  ElevatedButton(
                      onPressed: () => exit(0), child: const Text("Ya"))
                ],
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              if (_productController.showSearch.value)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Cari Produk",
                        label: Text("Cari Produk")),
                    onChanged: (value) {
                      _productController.searchText.value = value;
                    },
                  ),
                ),
              if (_productController.filterProduct.isEmpty)
                SizedBox(
                    height: _productController.showSearch.value
                        ? Get.height * 0.325
                        : Get.height * 0.4),
              _productController.filterProduct.isEmpty
                  ? const Center(
                      child: Text(
                      "Tidak ada produk",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ))
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _productController.filterProduct.length,
                        itemBuilder: (context, indexProduct) {
                          final listProduk = _productController
                              .filterProduct[indexProduct].obs;
                          // print(listProduk['terjual'].runtimeType);
                          final terjual = listProduk['terjual'];
                          final stok = listProduk['stok'];
                          final sisa = stok - terjual;
                          return InkWell(
                            onTap: () {
                              if (_productController.showCheckBoxRemove.value) {
                                bool isChecked = _productController
                                            .mapCheckBoxRemove[indexProduct]
                                        ['isSelected'] ==
                                    'true';
                                isChecked = !isChecked;

                                _productController
                                            .mapCheckBoxRemove[indexProduct]
                                        ['isSelected'] =
                                    isChecked
                                        ? true.toString()
                                        : false.toString();

                                _productController.mapCheckBoxRemove.refresh();
                              } else {
                                Get.to(() => LihatProduk(produk: listProduk));
                              }
                            },
                            onLongPress: () async {
                              _productController.showCheckBoxRemove.value =
                                  !_productController.showCheckBoxRemove.value;
                              if (_productController.showCheckBoxRemove.value) {
                                await _productController.generateMapCheckBox();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        if (listProduk['gambar'].isNotEmpty)
                                          logoProduk(listProduk['gambar'][0],
                                              sisa, 200, 2.5),
                                        if (listProduk['gambar'].isEmpty)
                                          noLogoProduk(170, sisa),
                                        if (_productController
                                            .showCheckBoxRemove.value)
                                          Obx(() {
                                            final isChecked = RxBool(
                                                _productController
                                                                .mapCheckBoxRemove[
                                                            indexProduct]
                                                        ['isSelected'] ==
                                                    'true');

                                            return Positioned(
                                              top: -8,
                                              right: -8,
                                              child: Transform.scale(
                                                scale: 1.2,
                                                child: Checkbox(
                                                  value: isChecked.value,
                                                  onChanged: (value) {
                                                    _productController
                                                                    .mapCheckBoxRemove[
                                                                indexProduct]
                                                            ['isSelected'] =
                                                        value.toString();

                                                    _productController
                                                        .mapCheckBoxRemove
                                                        .refresh();
                                                  },
                                                ),
                                              ),
                                            );
                                          })
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listProduk['produk'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Text(
                                          "Rp ${_productController.hargaProduk(listProduk)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.deepOrangeAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Terjual ${listProduk['terjual']}/${listProduk['stok']}',
                                          style: const TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }
}
