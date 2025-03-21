import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class DialogCheckoutKeranjang extends StatelessWidget with DialogPenjualan {
  DialogCheckoutKeranjang({
    super.key,
  });

  final KeranjangController _keranjangController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final TransaksiController _transaksiController = Get.find();
  final ProductController _productController = Get.find();
  final LaporanController _laporanController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.blue)),
      title: const Text(
        'Konfirmasi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text("Anda yakin menjual produk ini?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back(closeOverlays: false);
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () async {
              if (Settings.autentikasiAktif.value) {
                _biometrikController.hasAuthenticated.value =
                    await _biometrikController.authReuired();

                if (_biometrikController.hasAuthenticated.value) {
                  Get.back(closeOverlays: false);

                  confirmJual();
                } else {
                  Get.snackbar('Gagal', 'Autentikasi gagal',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red);
                }
              } else {
                Get.back(closeOverlays: false);

                confirmJual();
              }
            },
            child: const Text("Ya")),
      ],
    );
  }
}

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
      final List<String> listKey = [];
      List<Map<String, dynamic>> produk = [];
      for (int i = 0; i < _keranjangController.valueBox.length; i++) {
        if (_keranjangController.valueBox[i] == true) {
          final key = _keranjangController.keranjangProduk[i]['kode_produk'];
          listKey.add(key);
          final item = _productController.allProduct
              .where((p) => p['kode_produk'] == key)
              .first;
          final jumlahItem =
              int.tryParse(_keranjangController.jumlahControllers[i].text) ?? 1;
          final modal = int.tryParse(item['harga_beli'])!;
          // final omset = int.tryParse(item['harga_jual'])!;
          print(i);
          print(_keranjangController.hargaJualItem);
          final omset = _keranjangController.hargaJualItem[i];
          // produk[i]['harga_beli'] = modal * jumlahItem;
          // produk[i]['harga_jual'] = omset * jumlahItem;

          totaljumlah += jumlahItem;
          totalModal += modal * jumlahItem;
          totalOmset += omset;

          produk.add({
            'kode_produk': key,
            'terjual': jumlahItem,
            'harga_beli': modal * jumlahItem,
            'harga_jual': omset
          });
          await DBHelper.updateTerjual(key, jumlahItem);
        }
      }
      await _laporanController.tambahJual(produk, 'penjualan');

      await _keranjangController.removeProduk(listKey);

      final totalLaba = totalOmset - totalModal;
      await _transaksiController.addTransaksi(
          totaljumlah, listKey, totalModal, totalOmset, totalLaba);

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
