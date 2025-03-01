import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/home/animasi_transisi_tab.dart';

import 'package:myapp/laporan/penambahan/data_penambahan.dart';

import 'package:myapp/laporan/penjualan/data_penjualan.dart';
import 'package:myapp/laporan/perubahan/data_perubahan.dart';
import 'package:myapp/manager/manager_toko.dart';

class LaporanPenjualan extends StatelessWidget {
  static final indexLaporan = 1.obs;

  static final dariTahun = false.obs;
  static final dariBulan = false.obs;
  static final dariHari = false.obs;
  static final LaporanController _laporanController = Get.find();
  static final ManagerController _managerController = Get.find();
  const LaporanPenjualan({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    // border: Border.all(width: 2, color: Colors.blue),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: indexLaporan.value == 1
                      ? PenjualanData()
                      : indexLaporan.value == 2
                          ? PenambahanData()
                          : DataPerubahan(),
                ),
              ),
              if (_laporanController.showBarLaporan.value)
                BottomNavigationBar(
                  backgroundColor: Colors.blue,
                  // unselectedItemColor: Colors.white,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: const Color.fromARGB(185, 255, 255, 255),
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.edit_document), label: 'PERUBAHAN'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart_checkout),
                        label: 'PENJUALAN'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle), label: 'PENAMBAHAN')
                  ],
                  onTap: (value) {
                    indexLaporan.value = value;
                    if (value == 1 &&
                        _laporanController.viewMode.value == 'Rincian') {
                      _laporanController.viewMode.value = 'Transaksi';
                    } else if (value != 1 &&
                        _laporanController.viewMode.value != 'Rincian') {
                      _laporanController.viewMode.value = 'Rincian';
                    }
                  },
                  currentIndex: indexLaporan.value,
                ),
            ],
          ),
          if (_laporanController.showSliderScaler.value)
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Slider(
                          label: _laporanController.scaleTransformTable.value
                              .toStringAsFixed(2),
                          // overlayColor: WidgetStatePropertyAll(Colors.blue),
                          activeColor: Colors.blue,
                          max: 2,
                          min: 0.1,
                          divisions: 101,
                          value: _laporanController.scaleTransformTable.value,
                          onChanged: (value) => _laporanController
                              .scaleTransformTable.value = value),
                    ),
                  ),
                  // SizedBox(
                  //   width: Get.width * 0.8,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       ElevatedButton(
                  //           onPressed: () {
                  //             _laporanController.scaleTransformTable.value =
                  //                 _laporanController
                  //                     .oldScaleTransformTable.value;
                  //             _laporanController.showSliderScaler.value = false;
                  //           },
                  //           child: Icon(Icons.clear)),
                  //       SizedBox(
                  //         width: 8,
                  //       ),
                  //       ElevatedButton(
                  //           onPressed: () {
                  //             _laporanController.showSliderScaler.value = false;
                  //           },
                  //           child: Icon(Icons.check))
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          if (!_laporanController.showBarLaporan.value)
            Positioned(
              top: Get.height * 0.05,
              right: Get.width * 0.05,
              child: Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                  child: IconButton(
                      onPressed: () {
                        _laporanController.showMenuLaporan();
                      },
                      icon: Icon(Icons.more_vert, color: Colors.white))),
            ),
        ],
      );
    });
  }

  textEntry(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          softWrap: true,
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
