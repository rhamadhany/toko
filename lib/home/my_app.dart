import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/home/appbar_my_app.dart';
import 'package:myapp/laporan/body_laporan.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final BiometrikController _biometrikController = Get.find();

  final ProductController _productController = Get.find();
  // final KeranjangController _keranjangController =

  final LaporanController _laporanController = Get.find();
  final SplashController _splashController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: dialogTutup,
        child: Scaffold(
          appBar: _laporanController.showBarLaporan.value
              ? AppBar(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  title: AppBarMyApp(
                    isManager: false,
                  ),
                )
              : null,
          body: TabBarView(
              physics: _biometrikController.tabIndex.value == 2
                  ? const NeverScrollableScrollPhysics()
                  : null,
              controller: _biometrikController.tabController,
              children: [
                HomeToko(
                  isManager: false,
                ),
                // !_biometrikController.hasAuthenticated.value &&
                //         Settings.autentikasiAktif.value
                //     ? const Center(child: CircularProgressIndicator())
                //     : HomeToko(),
                // !_biometrikController.hasAuthenticated.value &&
                //         Settings.autentikasiAktif.value
                //     ? const Center(child: CircularProgressIndicator())
                //     : LaporanPenjualan(),
                const Settings()
              ]),
          bottomNavigationBar: _laporanController.showBarLaporan.value
              ? Container(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          const Color.fromARGB(185, 255, 255, 255),
                      controller: _biometrikController.tabController,
                      tabs: [
                        const Tab(text: "PRODUK", icon: Icon(Icons.shop)),
                        // const Tab(
                        //     text: "ADMIN",
                        //     icon: Icon(Icons.admin_panel_settings)),
                        // const Tab(
                        //   text: "LAPORAN",
                        //   icon: Icon(Icons.bar_chart),
                        // ),
                        Tab(
                          text: _splashController.username.value.toUpperCase(),
                          icon: const Icon(Icons.admin_panel_settings),
                        )
                      ]),
                )
              : null,
        ),
      );
    });
  }

  void dialogTutup(didPop, result) {
    if (_laporanController.showSliderScaler.value) {
      _laporanController.showSliderScaler.value = false;
    } else if (_laporanController.viewMode.value == 'Transaksi' &&
        _biometrikController.tabIndex.value == 2) {
      LaporanPenjualan.dariHari.value = false;
      _laporanController.viewMode.value = 'Hari';
    } else if (LaporanPenjualan.dariHari.value &&
        _biometrikController.tabIndex.value == 2 &&
        LaporanPenjualan.indexLaporan.value == 1) {
      LaporanPenjualan.dariHari.value = false;
      _laporanController.viewMode.value = 'Transaksi';
    } else if (LaporanPenjualan.dariHari.value &&
        _biometrikController.tabIndex.value == 2 &&
        LaporanPenjualan.indexLaporan.value != 1) {
      LaporanPenjualan.dariHari.value = false;
      _laporanController.viewMode.value = 'Hari';
    } else if (LaporanPenjualan.dariBulan.value &&
        _biometrikController.tabIndex.value == 2) {
      LaporanPenjualan.dariBulan.value = false;
      _laporanController.viewMode.value = 'Bulan';
    } else if (LaporanPenjualan.dariTahun.value &&
        _biometrikController.tabIndex.value == 2) {
      LaporanPenjualan.dariTahun.value = false;
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
}
