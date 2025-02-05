import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/laporan/penambahan/penambahan_data.dart';

import 'package:myapp/laporan/penjualan/penjualan_data.dart';
import 'package:myapp/laporan/perubahan/data_perubahan.dart';

class LaporanPenjualan extends StatelessWidget {
  static final indexLaporan = 1.obs;

  static final dariTahun = false.obs;
  static final dariBulan = false.obs;
  static final dariHari = false.obs;

  const LaporanPenjualan({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Expanded(
            child: indexLaporan.value == 1
                ? PenjualanData()
                : indexLaporan.value == 2
                    ? PenambahanData()
                    : DataPerubahan(),
          ),
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.edit_document), label: 'Perubahan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_checkout), label: 'Penjualan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle), label: 'Penambahan')
            ],
            onTap: (value) {
              indexLaporan.value = value;
            },
            currentIndex: indexLaporan.value,
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
