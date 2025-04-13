import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';
import 'package:myapp/lihat/lihat_produk.dart';
import 'package:myapp/pengaturan/settings.dart';

mixin ButtonDialogJualHelper on DialogJualHelper {
  final LaporanController _laporanController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final TransaksiController _transaksiController = Get.find();
  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController = Get.find();

  void pressKeranjang() {
    int jumlah = int.tryParse(jualController.value.text) ?? 1;
    final sisa = LihatProduk.produk['stok'] - LihatProduk.produk['terjual'];

    if (jumlah <= sisa) {
      if (jumlah == 0) {
        jumlah = 1;
      }
      final gambar = LihatProduk.produk['gambar'].isEmpty
          ? ""
          : LihatProduk.produk['gambar'][0];
      final minProduk = DialogJualHelper.selectedGrosir['min_produk'];
      final diskon = DialogJualHelper.selectedGrosir['diskon'];
      final grosir = DialogJualHelper.selectedGrosir['nama'];
      _keranjangController.addProduk(
          LihatProduk.produk['kode_produk'],
          LihatProduk.produk['produk'],
          jumlah,
          gambar,
          diskon,
          minProduk,
          grosir);

      Get.back(closeOverlays: true);
      HomeToko.focusPencarian.unfocus();
      Get.snackbar('Keranjang',
          '$jumlah ${LihatProduk.produk['produk']} ditambahkan ke keranjang',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 1));
    } else {
      Get.snackbar(
          "Tidak Cukup", "${LihatProduk.produk['produk']} hanya tersisa $sisa",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1));
      jualController.value.text = sisa.toString();
    }
  }

  Future<void> pressJual() async {
    if (Settings.autentikasiAktif.value) {
      _biometrikController.hasAuthenticated.value =
          await _biometrikController.authReuired();

      if (!_biometrikController.hasAuthenticated.value) {
        Get.snackbar('Gagal', 'Autentikasi gagal',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red);
        return;
      }
    }

    final count = jualController.value.text;
    int countInt = int.parse(count);

    final sisa =
        LihatProduk.produk['stok'] - (LihatProduk.produk['terjual'] + countInt);

    if (sisa > -1) {
      final terjualSebelumnya = LihatProduk.produk['terjual'];

      final terjualBaru = int.parse(jualController.value.text);
      if (terjualBaru <= 0) {
        Get.snackbar('Gagal', 'Masukkan jumlah yang dijual',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 1));
        return;
      }

      LihatProduk.produk['terjual'] = terjualSebelumnya + terjualBaru;
      final key = LihatProduk.produk['kode_produk'];

      Get.back(closeOverlays: true);
      HomeToko.focusPencarian.unfocus();
      final diskon = int.parse(totalHargaPotongan().value.toString());

      await DBHelper.updateTerjual(key, terjualBaru, diskon);
      final item = _productController.allProduct
          .where((im) => im['kode_produk'] == key)
          .first;
      final hBeli = int.tryParse(item['harga_beli'])!;
      // final hJual = int.tryParse(item['harga_jual'])!;
      final modal = hBeli * terjualBaru;
      final omset = int.parse(totalHargaSetelahDiskon().value);
      // final diskon = (hJual * terjualBaru) - omset;
      // print(totalHargaSetelahDiskon().value);
      await _laporanController.tambahJual([
        {
          'kode_produk': key,
          'terjual': terjualBaru,
          'harga_beli': modal,
          'harga_jual': omset,
          'diskon': diskon
        }
      ], 'penjualan');

      final laba = omset - modal;
      final List<String> listKey = [];
      listKey.add(key);
      await _transaksiController.addTransaksi(
          terjualBaru, listKey, modal, omset, laba, diskon);
      Get.snackbar('Terjual',
          '$terjualBaru ${LihatProduk.produk['produk']} telah dijual',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.purple,
          duration: const Duration(seconds: 1));
    } else {
      await stokTidakCukup(true);
    }
  }
}
