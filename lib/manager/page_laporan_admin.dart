import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/laporan/body_laporan.dart';
import 'package:myapp/manager/app_bar_kalender_lapoaran.dart';
import 'package:myapp/manager/pop_menu_laporan.dart';
import 'package:myapp/manager/view_mode_laporan.dart';

class PageLaporanAdmin extends GetView<LaporanController> {
  PageLaporanAdmin({super.key});
  final BiometrikController _biometrikController = Get.find();
  final LaporanController _laporanController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: !controller.showSliderScaler.value,
        onPopInvokedWithResult: (context, didPop) =>
            invokePopScope(context, didPop),
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              title: Row(
                children: [
                  Text(
                    titleLaporan(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Spacer(),
                  if ((_laporanController.viewMode.value != 'Tahun' &&
                          LaporanPenjualan.indexLaporan.value != 1) ||
                      (_laporanController.viewMode.value != 'Rincian' &&
                          LaporanPenjualan.indexLaporan.value == 1))
                    AppBarKalenderLapoaran(),
                  PopMenuLaporan()
                ],
              ),
            ),
            body: !_biometrikController.hasAuthenticated.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : LaporanPenjualan(),
            bottomNavigationBar: BottomAppBar(
              color: Colors.blue,
              child: TabBar(
                  controller: controller.tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      const Color.fromARGB(255, 164, 214, 255),
                  tabs: [
                    Tab(
                      text: 'PERUBAHAN',
                      icon: Icon(
                        Icons.edit_document,
                      ),
                    ),
                    Tab(
                      text: 'PENJUALAN',
                      icon: Icon(Icons.shopping_cart_checkout),
                    ),
                    Tab(
                      text: 'PENAMBAHAN',
                      icon: Icon(Icons.add_circle),
                    )
                  ]),
            )),
      );
    });
  }

  String titleLaporan() {
    return _laporanController.viewMode.value == 'Transaksi' &&
            LaporanPenjualan.indexLaporan.value == 1
        ? 'LAPORAN TRANSAKSI'
        : _laporanController.viewMode.value == 'Tahun'
            ? 'LAPORAN TAHUNAN'
            : _laporanController.viewMode.value == 'Bulan'
                ? 'LAPORAN BULANAN'
                : _laporanController.viewMode.value == 'Rincian'
                    ? 'RINCIAN PRODUK'
                    : 'LAPORAN HARIAN';
  }

  void dialogSwitchOpsi() {
    Get.dialog(ViewModeLaporan(laporanController: _laporanController));
  }

  void invokePopScope(didPop, result) {
    if (controller.showSliderScaler.value) {
      controller.showSliderScaler.value = false;
    } else if (controller.viewMode.value == 'Transaksi') {
      LaporanPenjualan.dariHari.value = false;
      controller.viewMode.value = 'Hari';
    } else if (LaporanPenjualan.dariHari.value &&
        LaporanPenjualan.indexLaporan.value == 1) {
      LaporanPenjualan.dariHari.value = false;
      controller.viewMode.value = 'Transaksi';
    } else if (LaporanPenjualan.dariHari.value &&
        LaporanPenjualan.indexLaporan.value != 1) {
      LaporanPenjualan.dariHari.value = false;
      controller.viewMode.value = 'Hari';
    } else if (LaporanPenjualan.dariBulan.value) {
      LaporanPenjualan.dariBulan.value = false;
      controller.viewMode.value = 'Bulan';
    } else if (LaporanPenjualan.dariTahun.value) {
      LaporanPenjualan.dariTahun.value = false;
      controller.viewMode.value = 'Tahun';
    } else {
      _biometrikController.hasAuthenticated.value = false;
    }
  }
}
