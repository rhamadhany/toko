import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';

mixin DialogJualHelper {
  // finak
  final RxMap<String, dynamic> produk = <String, dynamic>{}.obs;
  final RxBool showSnackbarStok = false.obs;
  final RxBool finishLongPress = false.obs;
  final jualController = TextEditingController(text: '0').obs;
  // final namaGrosir = ''.obs;
  // final potonganHarga = 0.obs;
  // final minimalJumlahPotongan = 0.obs;
  final defaultSelectedGrosir = {
    'nama': 'Normal',
    'min_produk': 0,
    'diskon': 0,
    'kode_diskon': '0'
  };
  static final RxList<Map<String, dynamic>> listGrosir =
      <Map<String, dynamic>>[].obs;
  static final selectedGrosir = <String, dynamic>{}.obs;
  static final Map<String, dynamic> controllerJumlahMinPotonganHarga = {
    'controller': TextEditingController(),
    'label': 'Jumlah Minimal'
  };
  static final Map<String, dynamic> controllerPotonganHarga = {
    'controller': TextEditingController(),
    'label': 'Potongan Harga'
  };
  static final Map<String, dynamic> controllerNamaGrosir = {
    'controller': TextEditingController(),
    'label': 'Nama Grosir'
  };

  RxString totalHargaPotongan() {
    if (int.tryParse(totalHargaSetelahDiskon().value) == null ||
        int.tryParse(produk['harga_jual']) == null ||
        int.tryParse(jualController.value.text) == null ||
        selectedGrosir.isEmpty) {
      return '0'.obs;
    }

    final hargaJual = int.parse(produk['harga_jual']);
    final jumlahTextField = int.parse(jualController.value.text);
    final hargaNormal = (hargaJual * jumlahTextField);
    final hargaDiskon =
        hargaNormal - int.parse(totalHargaSetelahDiskon().value);
    return hargaDiskon.toString().obs;
  }

  RxString totalHargaSetelahDiskon() {
    if (jualController.value.text == '0' ||
        jualController.value.text.isEmpty ||
        produk['harga_jual'] == null ||
        selectedGrosir.isEmpty ||
        selectedGrosir['min_produk'] == 0) {
      final jumlah = int.tryParse(jualController.value.text) ?? 0;
      final harga = int.tryParse(produk['harga_jual']) ?? 0;
      return (harga * jumlah).toString().obs;
    }
    final jumlah = int.tryParse(jualController.value.text) ?? 0;
    final harga = int.tryParse(produk['harga_jual']) ?? 0;
    final jumlahDiskon = jumlah / selectedGrosir['min_produk'].floor();

    final potongan = jumlahDiskon.floor() * selectedGrosir['diskon'].floor();

    final hitungDiskon = (jumlah * harga) - potongan;

    return hitungDiskon.toString().obs;
  }

  Future countJual(int count) async {
    final item = jualController.value.text;
    int lastItem = int.tryParse(item) ?? 0;
    int sisa = produk['stok'] - (produk['terjual']);

    if (count > sisa || (count > lastItem && lastItem > sisa)) {
      jualController.value.text = sisa.toString();
      await stokTidakCukup(false);
    } else {
      jualController.value.text = count.toString();
    }
    jualController.refresh();
  }

  Future<void> stokTidakCukup(bool isJual) async {
    if (!showSnackbarStok.value) {
      Get.snackbar("Stok",
          "${produk['produk']} hanya tersisa ${produk['stok'] - produk['terjual']} produk",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1));
      showSnackbarStok.value = true;
      if (isJual) {
        jualController.value.text =
            (produk['stok'] - produk['terjual']).toString();
      }

      await Future.delayed(const Duration(seconds: 3));
      showSnackbarStok.value = false;
    }
  }

  // void updateDiskon() {
  //   final keranjang = Get.find<KeranjangController>();
  //   final key = produk['kode_produk'];
  //   final index =
  //       keranjang.keranjangProduk.indexWhere((p) => p['kode_produk'] == key);
  //   if (index != -1) {
  //     // final produkKeranjang = keranjang.keranjangProduk[index];
  //     // final diskon = produkKeranjang['diskon'];
  //     // final minProduk = produkKeranjang['min_produk'];

  //     // potonganHarga.value = diskon;
  //     // minimalJumlahPotongan.value = minProduk;
  //     // controllerJumlahMinPotonganHarga['controller'].text =
  //     //     minimalJumlahPotongan.value.toString();
  //     // controllerPotonganHarga['controller'].text =
  //     //     potonganHarga.value.toString();
  //     // controllerNamaGrosir['controller'].text = namaGrosir.value;
  //   }
  // }

  void initController(String key) {
    final grosir = listGrosir.firstWhereOrNull((g) => g['kode_diskon'] == key);
    if (grosir != null) {
      controllerNamaGrosir['controller'].text = grosir['nama'];
      controllerJumlahMinPotonganHarga['controller'].text =
          grosir['min_produk'].toString();
      controllerPotonganHarga['controller'].text = grosir['diskon'].toString();
    }
  }
}
