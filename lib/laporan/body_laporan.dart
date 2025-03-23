import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';

import 'package:myapp/laporan/penambahan/data_penambahan.dart';

import 'package:myapp/laporan/penjualan/data_penjualan.dart';
import 'package:myapp/laporan/perubahan/data_perubahan.dart';

class LaporanPenjualan extends GetView<LaporanController> {
  static final indexLaporan = 1.obs;

  static final dariTahun = false.obs;
  static final dariBulan = false.obs;
  static final dariHari = false.obs;

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
                    alignment: Alignment.center,
                    height: Get.height,
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: TabBarView(
                        controller: controller.tabController,
                        children: [
                          DataPerubahan(),
                          PenjualanData(),
                          PenambahanData()
                        ])

                    // indexLaporan.value == 1
                    //     ? PenjualanData()
                    //     : indexLaporan.value == 2
                    //         ? PenambahanData()
                    //         : DataPerubahan(),
                    ),
              ),
              // if (controller.showBarLaporan.value)
              // BottomNavigationBar(
              //   backgroundColor: Colors.blue,
              //   selectedItemColor: Colors.white,
              //   unselectedItemColor: const Color.fromARGB(185, 255, 255, 255),
              //   items: const [
              //     BottomNavigationBarItem(
              //         icon: Icon(Icons.edit_document), label: 'PERUBAHAN'),
              //     BottomNavigationBarItem(
              //         icon: Icon(Icons.shopping_cart_checkout),
              //         label: 'PENJUALAN'),
              //     BottomNavigationBarItem(
              //         icon: Icon(Icons.add_circle), label: 'PENAMBAHAN')
              //   ],
              //   onTap: (value) {
              //     indexLaporan.value = value;
              //     if (value == 1 && controller.viewMode.value == 'Rincian') {
              //       controller.viewMode.value = 'Transaksi';
              //     } else if (value != 1 &&
              //         controller.viewMode.value != 'Rincian') {
              //       controller.viewMode.value = 'Rincian';
              //     }
              //   },
              //   currentIndex: indexLaporan.value,
              // ),
            ],
          ),
          if (controller.showSliderScaler.value)
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Slider(
                            label: controller.scaleTransformTable.value
                                .toStringAsFixed(2),
                            activeColor: Colors.blue,
                            max: 2,
                            min: 0.1,
                            divisions: 101,
                            value: controller.scaleTransformTable.value,
                            onChanged: (value) =>
                                controller.scaleTransformTable.value = value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!controller.showBarLaporan.value)
            Positioned(
              top: Get.height * 0.05,
              right: Get.width * 0.05,
              child: Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                  child: IconButton(
                      onPressed: () {
                        controller.showMenuLaporan();
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
