import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

mixin DialogPenjualan {
  final KeranjangController _keranjangController = Get.find();
  final TransaksiController _transaksiController = Get.find();
  final ProductController _productController = Get.find();
  final LaporanController _laporanController = Get.find();

  Future<void> confirmJual() async {
    if (HalamanKeranjang.haveValueBox()) {
      int totaljumlah = 0;
      int totalModal = 0;
      int totalOmset = 0;
      int totalDiskon = 0;
      final List<String> listKey = [];
      List<Map<String, dynamic>> produk = [];
      for (int i = 0; i < _keranjangController.valueBox.length; i++) {
        if (_keranjangController.valueBox[i]['value'] == true) {
          final key = _keranjangController.keranjangProduk[i]['kode_produk'];
          listKey.add(key);
          final item = _productController.allProduct
              .where((p) => p['kode_produk'] == key)
              .first;
          final jumlahItem = int.tryParse(
                  _keranjangController.valueBox[i]['controller'].text) ??
              1;
          final grosir = _keranjangController.keranjangProduk[i]['grosir'];
          int diskon = _keranjangController.hargaPotonganDiskon[i];
          final modal = int.tryParse(item['harga_beli'])!;
          // final omset = int.tryParse(item['harga_jual'])!;
          final omset = _keranjangController.hargaJualItem[i];
          // produk[i]['harga_beli'] = modal * jumlahItem;
          // produk[i]['harga_jual'] = omset * jumlahItem;

          totaljumlah += jumlahItem;
          totalModal += modal * jumlahItem;
          totalOmset += omset;
          totalDiskon += diskon;

          produk.add({
            'kode_produk': key,
            'terjual': jumlahItem,
            'harga_beli': modal * jumlahItem,
            'harga_jual': omset,
            'diskon': diskon,
            'grosir': grosir
          });
          // print('diskon: $diskon, totalDiskon: $totalDiskon');
          await DBHelper.updateTerjual(key, jumlahItem, diskon);
        }
      }
      await _laporanController.tambahJual(produk, 'penjualan');

      await _keranjangController.removeProduk(listKey);

      final totalLaba = totalOmset - totalModal;
      await _transaksiController.addTransaksi(
        totaljumlah,
        listKey,
        totalModal,
        totalOmset,
        totalLaba,
        totalDiskon,
      );

      await _keranjangController.initValueBox();

      Get.snackbar("Terjual", "Penjualan Selesai",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.purple);
    } else {
      Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  // void hitungSatuanItem(
  //     int minProduk, int diskon, int hargaNormal, int jumlah) {
  //   int hargaItem = hargaNormal;
  //   if (minProduk > 0 && diskon > 0) {
  //     int harga = minProduk * hargaNormal;
  //     int hargaDiskon = harga - diskon;
  //     hargaItem = hargaDiskon;
  //   }
  //   // _keranjangController.hargaJualItem.add(hargaItem);

  //   print(hargaItem);
  // }
}
