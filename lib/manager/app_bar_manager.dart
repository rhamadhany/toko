import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/home/appbar_my_app.dart';
import 'package:myapp/laporan/body_laporan.dart';
import 'package:myapp/manager/app_bar_kalender_lapoaran.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:myapp/manager/view_mode_laporan.dart';
import 'package:myapp/pengaturan/printing_qr.dart';

class AppBarManager extends GetView<ManagerController> {
  AppBarManager({super.key});

  final ProductController _productController = Get.find();
  final LaporanController _laporanController = Get.find();

  @override
  Widget build(BuildContext context) {
    // return Container();
    return Row(
      children: [
        Text(
          controller.tabIndex.value == 0
              ? 'PRODUK'
              : controller.tabIndex.value == 1
                  ? titleLaporan()
                  : 'PENGATURAN',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        Spacer(),
        if (!_productController.showCheckBoxRemove.value &&
            controller.tabIndex.value == 0)
          dynamicIconAppBar(_productController, true),
        if (_productController.showCheckBoxRemove.value &&
            controller.tabIndex.value == 0)
          IconButton(
              onPressed: () {
                PrintingQR(dariBox: true.obs).dialogQR();
              },
              icon: Icon(Icons.print)),
        if (_productController.showCheckBoxRemove.value &&
            controller.tabIndex.value == 0)
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
        if ((controller.tabIndex.value == 1 &&
                _laporanController.viewMode.value != 'Tahun' &&
                LaporanPenjualan.indexLaporan.value != 1) ||
            (controller.tabIndex.value == 1 &&
                _laporanController.viewMode.value != 'Rincian' &&
                LaporanPenjualan.indexLaporan.value == 1))
          AppBarKalenderLapoaran(),
        if (controller.tabIndex.value == 1)
          IconButton(
              onPressed: () {
                dialogSwitchOpsi();
              },
              icon: const Icon(Icons.calendar_month, color: Colors.white)),
        if (controller.tabIndex.value == 1)
          IconButton(
              onPressed: () {
                _laporanController.oldScaleTransformTable.value =
                    _laporanController.scaleTransformTable.value;
                _laporanController.showSliderScaler.value =
                    !_laporanController.showSliderScaler.value;
              },
              icon: Icon(Icons.zoom_in))
      ],
    );
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
}
