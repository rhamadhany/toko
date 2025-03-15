import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/product_controller.dart';

import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class KeranjangController extends GetxController {
  Database? database;
  final RxList<Map<String, dynamic>> keranjangProduk =
      <Map<String, dynamic>>[].obs;
  final hasSnackbar = false.obs;

  final ProductController _productController = Get.find();
  final RxList<TextEditingController> jumlahControllers =
      RxList<TextEditingController>();
  final RxList<bool> valueBox = RxList<bool>();
  final boxAll = false.obs;
  final hargaJual = [];
  final isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    keranjangProdukListener();
  }

  void keranjangProdukListener() {
    keranjangProduk.listen((_) async {
      update();
    });

    valueBox.listen((_) {
      if (valueBox.any((box) => box == false)) {
        boxAll.value = false;
      } else if (valueBox.every((box) => box == true)) {
        boxAll.value = true;
      }
    });
  }

  Future<void> initValueBox() async {
    isLoading.value = true;
    hargaJual.clear();

    await loadProduk();

    final keranjangLength = keranjangProduk.length;

    valueBox.clear();
    jumlahControllers.clear();
    valueBox.addAll(List.generate(keranjangLength, (_) => false));

    jumlahControllers.clear();
    jumlahControllers.addAll(List.generate(keranjangLength, (index) {
      return TextEditingController(
          text: keranjangProduk[index]['jumlah'].toString());
    }));

    hargaJual.clear();
    hargaJual.addAll(List.generate(keranjangLength, (index) {
      final product = _productController.allProduct.firstWhere(
          (produk) =>
              produk['kode_produk'] == keranjangProduk[index]['kode_produk'],
          orElse: () => {});
      return product['harga_jual'] ?? 0;
    }));

    isLoading.value = false;
  }

  Future<void> loadProduk() async {
    try {
      final uri = Uri.parse('$domain/produk/load.php');
      final response = await http.post(uri, body: {'tabel': 'keranjang'});
      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        keranjangProduk.value = List<Map<String, dynamic>>.from(decode);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed load produk keranjang',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  Future<void> addProduk(key, produk, jumlah, gambar) async {
    final indexKeys =
        keranjangProduk.indexWhere((pro) => pro['kode_produk'] == key);

    if (indexKeys != -1) {
      final updateKey = keranjangProduk[indexKeys]['kode_produk'];
      final jumlahBaru = keranjangProduk[indexKeys]['jumlah'] + jumlah;

      await updateJumlah(updateKey, jumlahBaru);
    } else {
      final map = jsonEncode([
        {
          'tanggal': DateTime.now().toString(),
          'kode_produk': key,
          'produk': produk,
          'jumlah': jumlah,
          'gambar': gambar,
        }
      ]);
      final uri = Uri.parse('$domain/produk/tambah.php');
      await http.post(uri, body: {'tabel': 'keranjang', 'produk': map});
    }

    await initValueBox();
  }

  Future<void> removeProduk(List<String> listKey) async {
    try {
      final uri = Uri.parse('$domain/produk/delete.php');
      await http.post(uri,
          body: {'tabel': 'keranjang', 'list_kode': jsonEncode(listKey)});
      await loadProduk();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove produk dari keranjang $e',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void refreshProduk() {
    loadProduk();
  }

  Future<void> updateJumlah(String key, int jumlahUpdate) async {
    final index = indexKey(key);

    if (index != -1) {
      final stok = _productController.allProduct[index]['stok'];
      final terjual = _productController.allProduct[index]['terjual'];
      final produk = _productController.allProduct[index]['produk'];
      final sisa = stok - terjual;

      if (jumlahUpdate > sisa) {
        jumlahUpdate = sisa;
        if (!hasSnackbar.value) {
          hasSnackbar.value = true;
          Get.snackbar(
            "Stok",
            "$produk hanya tersisa $sisa",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red,
          );
          await Future.delayed(const Duration(seconds: 3));
          hasSnackbar.value = false;
        }
      }

      final url = Uri.parse('$domain/produk/update_keranjang.php');
      await http.post(url,
          body: {'kode_produk': key, 'jumlah': jumlahUpdate.toString()});
      await loadProduk();
    }
  }

  int indexKey(String key) {
    return _productController.allProduct
        .indexWhere((pro) => pro['kode_produk'] == key);
  }

  int sisaPadaAllProduk(String key) {
    int sisa = -1;
    final indexkey = _productController.allProduct
        .indexWhere((produk) => produk['kode_produk'] == key);
    if (indexkey != -1) {
      final stok = _productController.allProduct[indexkey]['stok'];
      final terjual = _productController.allProduct[indexkey]['terjual'];
      sisa = stok - terjual;
    }
    return sisa;
  }

  Future<void> langsungtambahkeKeranjang(
      int sisa, RxMap<String, dynamic> produkBaru) async {
    if (sisa > 0) {
      final gambar =
          produkBaru['gambar'].isEmpty ? "" : produkBaru['gambar'][0];
      await addProduk(
          produkBaru['kode_produk'], produkBaru['produk'], 1, gambar);

      Get.back(closeOverlays: true);

      HomeToko.focusPencarian.unfocus();

      Get.snackbar(
          "Keranjang", '${produkBaru['produk']} ditambahkan ke keranjang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.purple,
          colorText: Colors.white,
          duration: const Duration(seconds: 1));
    } else {
      Get.snackbar("Stok", "${produkBaru['produk']} kosong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 1));
    }
  }
}
