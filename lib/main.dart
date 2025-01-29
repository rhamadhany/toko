// import 'dart:ui';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/beranda_toko.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/laporan_penjualan.dart';
import 'package:myapp/controller/main_controller.dart';
import 'package:myapp/produk_baru.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/pengaturan/settings.dart';

void main() {
  Get.put(BiometrikController());
  Get.put(
      KeranjangController()); // Ini sudah permanen karena menggunakan Get.put
  Get.put(ProductController());
  Get.put(MainController());

  runApp(GetMaterialApp(
    home: MyApp(),
    theme: ThemeData(),
    darkTheme: ThemeData.dark(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final BiometrikController _biometrikController = Get.find();

  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController =
      Get.put(KeranjangController());
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
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  _biometrikController.tabIndex.value == 0
                      ? "Toko"
                      : _biometrikController.tabIndex.value == 1
                          ? "Rincian"
                          : _biometrikController.tabIndex.value == 2
                              ? "Laporan"
                              : "Pengaturan",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_biometrikController.tabIndex.value == 0 ||
                    (_biometrikController.tabIndex.value == 1 &&
                        (_biometrikController.hasAuthenticated.value ||
                            !Settings.autentikasiAktif.value)))
                  IconButton(
                      onPressed: () {
                        _productController.showSearch.value =
                            !_productController.showSearch.value;

                        if (!_productController.showSearch.value) {
                          _productController.searchText.value = '';
                        }
                      },
                      icon: const Icon(Icons.search)),
                IconButton(
                    onPressed: () {
                      Get.to(() => HalamanKeranjang());
                    },
                    icon: const Icon(Icons.shopping_cart_checkout))
              ],
            ),
          ),
          body: TabBarView(
              controller: _biometrikController.tabController,
              children: [
                HomeToko(
                  productController: _productController,
                  biometrikController: _biometrikController,
                ),
                !_biometrikController.hasAuthenticated.value &&
                        Settings.autentikasiAktif.value
                    ? const Center(child: CircularProgressIndicator())
                    : HomeToko(
                        productController: _productController,
                        biometrikController: _biometrikController,
                      ),
                !_biometrikController.hasAuthenticated.value &&
                        Settings.autentikasiAktif.value
                    ? const Center(child: CircularProgressIndicator())
                    : const LaporanPenjualan(),
                const Settings()
              ]),
          bottomNavigationBar: TabBar(
              controller: _biometrikController.tabController,
              tabs: const [
                Tab(text: "Beranda", icon: Icon(Icons.home)),
                Tab(text: "Rincian", icon: Icon(Icons.list)),
                Tab(
                  text: "Laporan",
                  icon: Icon(Icons.bar_chart),
                ),
                Tab(
                  text: "Pengaturan",
                  icon: Icon(Icons.settings),
                )
              ]),
          floatingActionButton: (!_biometrikController.hasAuthenticated.value &&
                      Settings.autentikasiAktif.value) ||
                  _biometrikController.tabIndex.value != 1
              ? null
              : FloatingActionButton(
                  onPressed: () async {
                    if (_productController.showCheckBoxRemove.value &&
                        _productController.filterProduct.isNotEmpty) {
                      final existSelect = _productController.mapCheckBoxRemove
                          .any((any) => any['isSelected'] == 'true');

                      if (!existSelect) {
                        Get.snackbar("Error", "Pilih setidaknya 1 produk",
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }

                      bool? confirm = await confirmationDelete();
                      if (!confirm) {
                        return;
                      }
                      List<String> listKey = [];
                      for (int i = 0;
                          i < _productController.filterProduct.length;
                          i++) {
                        if (_productController.mapCheckBoxRemove[i]
                                    ['isSelected'] ==
                                'true' &&
                            _productController.mapCheckBoxRemove[i]['key'] !=
                                "") {
                          listKey.add(
                              _productController.mapCheckBoxRemove[i]['key']!);
                        }
                      }
                      for (int k = 0; k < listKey.length; k++) {
                        await _keranjangController.removeProduk(listKey[k]);
                      }

                      await DBHelper.deleteProduct(listKey);
                      await _keranjangController.loadProduk();
                      await _productController.generateMapCheckBox();
                    } else {
                      for (final controller
                          in _productController.listTextField) {
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
        ),
      );
    });
  }

  Future<bool> confirmationDelete() async {
    final bool? confirm = await Get.dialog<bool?>(AlertDialog(
      title: const Text("Konfirmasi"),
      content: const Text("Anda yakin untuk menghapus produk ini?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text("Ya")),
      ],
    ));
    return confirm ?? false;
  }
}
