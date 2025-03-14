import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/body_laporan.dart';
import 'package:myapp/laporan/kalender_picker.dart';

class AppBarKalenderLapoaran extends StatelessWidget {
  AppBarKalenderLapoaran({super.key});
  final ProductController _productController = Get.find();
  final LaporanController _laporanController = Get.find();
  @override
  Widget build(BuildContext context) {
    // return Container();
    return TextButton(
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
        ));
  }
}

  // TextButton appBarKalenderLaporan(LaporanController laporanController) {

  // }