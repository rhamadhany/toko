import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/beranda_toko.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/laporan/kalender_picker.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class AppBarMyApp extends StatelessWidget {
  AppBarMyApp({super.key});

  final BiometrikController _biometrikController = Get.find();

  final ProductController _productController = Get.find();
  final LaporanController _laporanController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          Text(
            _biometrikController.tabIndex.value == 0
                ? "Toko"
                : _biometrikController.tabIndex.value == 1
                    ? "Rincian"
                    : _biometrikController.tabIndex.value == 2
                        ? "Laporan ${titleLaporan()}"
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
                  Get.to(() => const HalamanKeranjang());
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

                    _productController.mapCheckBoxRemove.refresh();
                  }
                },
                icon: const Icon(Icons.select_all)),
          if (_biometrikController.tabIndex.value == 2 &&
              _laporanController.viewMode.value != 'Tahun')
            TextButton(
                onPressed: () async {
                  if (_laporanController.viewMode.value == 'Hari') {
                    Get.dialog(KalenderPicker(
                      tampilkandaftarTahun: false.obs,
                      dariHari: true.obs,
                    ));
                  } else {
                    Get.dialog(KalenderPicker(
                      tampilkandaftarTahun: true.obs,
                      dariHari: false.obs,
                    ));
                  }
                },
                child: Text(_laporanController.viewMode.value == 'Hari'
                    ? '${_laporanController.bulanTerpilih.value} ${_laporanController.tahunTerpilih.value}'
                    : _laporanController.tahunTerpilih.value.toString())),
          if (_biometrikController.tabIndex.value == 2)
            IconButton(
                onPressed: () {
                  dialogSwitchOpsi();
                },
                icon: const Icon(Icons.calendar_month)),
        ],
      );
    });
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
              Get.back();
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
              Get.back();
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
              Get.back();
            },
          ),
        ],
      ),
    ));
  }

  pilihBulan() {
    Get.dialog(AlertDialog(
      content: SizedBox(
        height: 200,
        child: CupertinoPicker(
            itemExtent: 30,
            onSelectedItemChanged: (int value) {},
            children: List.generate(12, (index) {
              return Text(index.toString());
            })),
      ),
    ));
  }

  String titleLaporan() {
    return _laporanController.viewMode.value == 'Hari'
        ? 'Harian'
        : _laporanController.viewMode.value == 'Bulan'
            ? 'Bulanan'
            : 'Tahunan';
  }
}
