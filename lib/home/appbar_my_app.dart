import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/laporan/kalender_picker.dart';
import 'package:myapp/laporan/laporan_penjualan.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/printing_qr.dart';
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
                    ? "Admin"
                    : _biometrikController.tabIndex.value == 2
                        ? _laporanController.viewMode.value == 'Rincian'
                            ? 'Rincian Produk'
                            : "Laporan ${titleLaporan()}"
                        : "Pengaturan",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
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
                icon: const Icon(Icons.search, color: Colors.white)),
          if (!_productController.showCheckBoxRemove.value &&
              (_biometrikController.tabIndex.value == 0 ||
                  _biometrikController.tabIndex.value == 1))
            IconButton(
                onPressed: () {
                  Get.to(() => const HalamanKeranjang());
                },
                icon: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                )),
          if (_productController.showCheckBoxRemove.value)
            IconButton(
                onPressed: () {
                  PrintingQR(dariBox: true.obs).dialogQR();
                },
                icon: Icon(Icons.print)),
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
                icon: const Icon(Icons.select_all, color: Colors.white)),
          if ((_biometrikController.tabIndex.value == 2 &&
                  _laporanController.viewMode.value != 'Tahun' &&
                  LaporanPenjualan.indexLaporan.value != 1) ||
              (_biometrikController.tabIndex.value == 2 &&
                  _laporanController.viewMode.value != 'Rincian' &&
                  LaporanPenjualan.indexLaporan.value == 1))
            TextButton(
                onPressed: () async {
                  if (_laporanController.viewMode.value == 'Rincian' ||
                      _laporanController.viewMode.value == 'Transaksi') {
                    Get.dialog(KalenderPicker(
                      tampilkandaftarTahun: false.obs,
                      dariHari: false.obs,
                      tampilkanTanggal: true.obs,
                      dariRincian: true.obs,
                    ));
                  } else if (_laporanController.viewMode.value == 'Hari') {
                    Get.dialog(KalenderPicker(
                      tampilkandaftarTahun: false.obs,
                      dariHari: true.obs,
                      tampilkanTanggal: false.obs,
                      dariRincian: false.obs,
                    ));
                  } else {
                    Get.dialog(KalenderPicker(
                      tampilkandaftarTahun: true.obs,
                      dariHari: false.obs,
                      tampilkanTanggal: false.obs,
                      dariRincian: false.obs,
                    ));
                  }
                },
                child: Text(
                  (_laporanController.viewMode.value == 'Rincian' &&
                              LaporanPenjualan.indexLaporan.value != 1) ||
                          (_laporanController.viewMode.value == 'Transaksi' &&
                              LaporanPenjualan.indexLaporan.value == 1)
                      ? _productController.tanggalHarian.value
                      : _laporanController.viewMode.value == 'Hari'
                          ? '${_laporanController.bulanTerpilih.value} ${_laporanController.tahunTerpilih.value}'
                          : _laporanController.tahunTerpilih.value.toString(),
                  style: const TextStyle(color: Colors.white),
                )),
          if (_biometrikController.tabIndex.value == 2)
            IconButton(
                onPressed: () {
                  dialogSwitchOpsi();
                },
                icon: const Icon(Icons.calendar_month, color: Colors.white)),
          if (_biometrikController.tabIndex.value == 2)
            IconButton(
                onPressed: () {
                  _laporanController.oldScaleTransformTable.value =
                      _laporanController.scaleTransformTable.value;
                  _laporanController.showSliderScaler.value =
                      !_laporanController.showSliderScaler.value;
                },
                icon: Icon(Icons.zoom_out))
        ],
      );
    });
  }

  void dialogSwitchOpsi() {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue)),
      title: Card(
        color: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Mode',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
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
          if (LaporanPenjualan.indexLaporan.value == 1)
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Transaksi'),
              trailing: _laporanController.viewMode.value == 'Transaksi'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                _laporanController.viewMode.value = 'Transaksi';
                Get.back();
              },
            ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Rincian'),
            trailing: _laporanController.viewMode.value == 'Rincian'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Rincian';
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
    return _laporanController.viewMode.value == 'Transaksi' &&
            LaporanPenjualan.indexLaporan.value == 1
        ? 'Transaksi'
        : _laporanController.viewMode.value == 'Tahun'
            ? 'Tahunan'
            : _laporanController.viewMode.value == 'Bulan'
                ? 'Bulanan'
                : 'Harian';
  }
}
