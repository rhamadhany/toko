// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/beranda_toko.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class AppBarMyApp extends StatelessWidget {
  AppBarMyApp({super.key});

  final BiometrikController _biometrikController = Get.find();

  final ProductController _productController = Get.find();
  final LaporanController _laporanController = Get.find();
  // final KeranjangController _keranjangController =
  @override
  Widget build(BuildContext context) {
    return Row(
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
                        !Settings.autentikasiAktif.value)) &&
                !_productController.showCheckBoxRemove.value)
          IconButton(
              onPressed: () {
                _productController.showSearch.value =
                    !_productController.showSearch.value;

                if (!_productController.showSearch.value) {
                  _productController.searchText.value = '';
                  HomeToko.focusPencarian.requestFocus();
                }
              },
              icon: const Icon(Icons.search)),
        if (!_productController.showCheckBoxRemove.value &&
            (_biometrikController.tabIndex.value == 0 ||
                _biometrikController.tabIndex.value == 1))
          IconButton(
              onPressed: () {
                Get.to(() => HalamanKeranjang());
              },
              icon: const Icon(Icons.shopping_cart_checkout)),
        if (_productController.showCheckBoxRemove.value)
          IconButton(
              onPressed: () {
                for (int i = 0;
                    i < _productController.mapCheckBoxRemove.length;
                    i++) {
                  _productController.mapCheckBoxRemove[i]['isSelected'] =
                      _productController.mapCheckBoxRemove[i]['isSelected'] ==
                              'true'
                          ? 'false'
                          : 'true';
                  // print(
                  // _productController.mapCheckBoxRemove[i]['isSelected']);
                  // _productController.update();

                  _productController.mapCheckBoxRemove.refresh();
                }
              },
              icon: const Icon(Icons.select_all)),
        // if (_biometrikController.tabIndex.value == 2)
        //   TextButton(
        //       onPressed: () {},
        //       child: Text((DateTime.now().day + 1).toString())),
        // if (_biometrikController.tabIndex.value == 2)
        //   TextButton(
        //       onPressed: () {},
        //       child: Text(namaBulan[DateTime.now().month - 1])),
        // if (_biometrikController.tabIndex.value == 2)
        //   TextButton(
        //       onPressed: () {},
        //       child: Text((DateTime.now().year).toString())),
        if (_biometrikController.tabIndex.value == 2)
          IconButton(
              onPressed: () {
                dialogSwitchOpsi();
              },
              icon: const Icon(Icons.expand)),
        if (_biometrikController.tabIndex.value == 2)
          IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month)),
      ],
    );
  }

  void dialogSwitchOpsi() {
    Get.dialog(AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_view_day),
            title: const Text('Tahun'),
            trailing: _laporanController.viewMode.value == 'Tahun'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Tahun';
              Get.back(); // Menutup dialog setelah pilihan
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Bulan'),
            trailing: _laporanController.viewMode.value == 'Bulan'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Bulan';
              Get.back(); // Menutup dialog setelah pilihan
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Hari'),
            trailing: _laporanController.viewMode.value == 'Hari'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Hari';
              Get.back(); // Menutup dialog setelah pilihan
            },
          ),
        ],
      ),
    ));
  }
}
