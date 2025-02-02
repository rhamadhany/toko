import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/penjualan/laporan_bulanan.dart';
import 'package:myapp/laporan/penjualan/laporan_harian.dart';
import 'package:myapp/laporan/penjualan/laporan_tahunan.dart';

class LaporanPenjualan extends StatelessWidget {
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  static final indexLaporan = 1.obs;
  static final headList = ['Tanggal', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  static final headList2 =
      ['Tanggal', 'Produk', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  LaporanPenjualan({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: _laporanController.viewMode.value == 'Hari'
                    ? LaporanHarian()
                    : _laporanController.viewMode.value == 'Bulan'
                        ? LaporanBulanan()
                        : LaporanTahunan()),
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
