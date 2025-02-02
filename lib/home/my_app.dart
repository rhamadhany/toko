import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/home/appbar_my_app.dart';
import 'package:myapp/laporan/penjualan/laporan_bulanan.dart';
import 'package:myapp/laporan/penjualan/laporan_harian.dart';
import 'package:myapp/laporan/penjualan/laporan_penjualan.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:myapp/produk%20baru/produk_baru.dart';
import 'package:myapp/tes/generate.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final BiometrikController _biometrikController = Get.find();

  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController =
      Get.put(KeranjangController());
  final LaporanController _laporanController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: dialogTutup,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            title: AppBarMyApp(),
          ),
          body: TabBarView(
              physics: _biometrikController.tabIndex.value == 2
                  ? const NeverScrollableScrollPhysics()
                  : null,
              controller: _biometrikController.tabController,
              children: [
                HomeToko(),
                !_biometrikController.hasAuthenticated.value &&
                        Settings.autentikasiAktif.value
                    ? const Center(child: CircularProgressIndicator())
                    : HomeToko(),
                !_biometrikController.hasAuthenticated.value &&
                        Settings.autentikasiAktif.value
                    ? const Center(child: CircularProgressIndicator())
                    : LaporanPenjualan(),
                const Settings()
              ]),
          bottomNavigationBar: TabBar(
              controller: _biometrikController.tabController,
              tabs: const [
                Tab(text: "Produk", icon: Icon(Icons.home)),
                Tab(text: "Admin", icon: Icon(Icons.people)),
                Tab(
                  text: "Laporan",
                  icon: Icon(Icons.bar_chart),
                ),
                Tab(
                  text: "Pengaturan",
                  icon: Icon(Icons.settings),
                )
              ]),
          floatingActionButton: _biometrikController.tabIndex.value == 3
              ? GenerateItem.textGenerate()
              : (!_biometrikController.hasAuthenticated.value &&
                          Settings.autentikasiAktif.value) ||
                      _biometrikController.tabIndex.value != 1
                  ? null
                  : FloatingActionButton(
                      onPressed: () async {
                        if (_productController.showCheckBoxRemove.value &&
                            _productController.filterProduct.isNotEmpty) {
                          final existSelect = _productController
                              .mapCheckBoxRemove
                              .any((any) => any['isSelected'] == 'true');

                          if (!existSelect) {
                            Get.snackbar("Error", "Pilih setidaknya 1 produk",
                                snackPosition: SnackPosition.BOTTOM,
                                colorText: Colors.white,
                                backgroundColor: Colors.red);
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
                                _productController.mapCheckBoxRemove[i]
                                        ['key'] !=
                                    "") {
                              listKey.add(_productController
                                  .mapCheckBoxRemove[i]['key']!);
                            }
                          }
                          for (int k = 0; k < listKey.length; k++) {
                            await _keranjangController.removeProduk(listKey[k]);
                          }

                          await DBHelper.deleteProduct(listKey);
                          await _keranjangController.loadProduk();
                          await _productController.generateMapCheckBox();
                        } else {
                          _productController.kategoriTerpilih.value = 'Semua';
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

  void dialogTutup(didPop, result) {
    if (LaporanHarian.dariBulan.value &&
        _biometrikController.tabIndex.value == 2) {
      LaporanHarian.dariBulan.value = false;
      _laporanController.viewMode.value = 'Bulan';
    } else if (LaporanBulanan.dariTahun.value &&
        _biometrikController.tabIndex.value == 2) {
      LaporanBulanan.dariTahun.value = false;
      _laporanController.viewMode.value = 'Tahun';
    } else if (_productController.showCheckBoxRemove.value) {
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
            ElevatedButton(onPressed: () => exit(0), child: const Text("Ya"))
          ],
        ),
      );
    }
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
