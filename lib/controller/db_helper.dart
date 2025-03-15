import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:http/http.dart' as http;

class DBHelper with SnackHelper {
  static final ProductController _productController =
      Get.find<ProductController>();
  static final LaporanController _laporanController = Get.find();

  static Future<List<Map<String, dynamic>>> loadProducts() async {
    try {
      final uri = Uri.parse('$domain/produk/load.php');
      final response = await http.post(uri, body: {'tabel': 'produk'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = List<Map<String, dynamic>>.from(data);

        final processedResult = result.map((row) {
          final newRow = Map<String, dynamic>.from(row);
          try {
            newRow['gambar'] = jsonDecode(row['gambar']);
          } catch (e) {
            newRow['gambar'] = "";
          }
          return newRow;
        }).toList();
        return processedResult;
      }
    } catch (e) {
      SnackHelper.snackError(content: 'Error load produk');
      return [];
    }
    return [];
  }

  static Future<void> addProduct(
      String product,
      String hargaBeli,
      String hargaJual,
      int terjual,
      int stock,
      List<Map<String, dynamic>> listGambar,
      String kategori,
      String deskripsi) async {
    try {
      final random = Random();

      final date = DateTime.now();
      final format = DateFormat('HHmmss');
      final formattedDate = format.format(date);
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

      final rString = String.fromCharCodes(Iterable.generate(
          8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
      final keyString = formattedDate + rString;
      final key = base64Encode(utf8.encode(keyString));

      final mapProduk = {
        'kode_produk': key,
        'tanggal': DateTime.now().toString(),
        'produk': product,
        'harga_beli': hargaBeli,
        'harga_jual': hargaJual,
        'terjual': terjual,
        'stok': stock,
        'gambar': listGambar,
        'kategori': kategori,
        'deskripsi': deskripsi,
      };

      final uri = Uri.parse('$domain/produk/tambah.php');

      final decodeMap = jsonEncode([mapProduk]);
      await http.post(uri, body: {'produk': decodeMap, 'tabel': 'produk'});

      await http.post(uri, body: {'produk': decodeMap, 'tabel': 'penambahan'});
      await _laporanController.loadProduk();
      _productController.allProduct.value = await loadProducts();
    } catch (error) {
      await SnackHelper.snackError(content: 'Gagal menambahkan produk');
    }
  }

  static Future updateTerjual(String key, int terjual) async {
    final url = Uri.parse('$domain/produk/update_produk_terjual.php');
    final encode = jsonEncode({'kode_produk': key, 'terjual': terjual});
    await http.post(url, body: {'encode': encode});
    _productController.allProduct.value = await loadProducts();
  }

  static Future updateProduct(
      RxMap<String, dynamic> produk, bool isEditing) async {
    final tanggal = DateTime.now().toString();

    final mapProduk = {...produk, 'tanggal': tanggal};

    if (isEditing) {
      final url = Uri.parse('$domain/produk/update_perubahan.php');
      final newMap = jsonEncode({
        'tanggal': mapProduk['tanggal'],
        'kode_produk': mapProduk['kode_produk'],
        'produk_baru': mapProduk['produk'],
        'harga_beli_baru': mapProduk['harga_beli'],
        'harga_jual_baru': mapProduk['harga_jual'],
        'terjual_baru': mapProduk['terjual'],
        'stok_baru': mapProduk['stok'],
        'gambar_baru': mapProduk['gambar'],
        'kategori_baru': mapProduk['kategori'],
        'deskripsi_baru': mapProduk['deskripsi']
      });
      await http.post(url, body: {
        'produk': newMap,
      });

      await _laporanController.loadProduk();
    }

    final encodeMap = jsonEncode(mapProduk);
    final url = Uri.parse('$domain/produk/update_produk.php');
    await http.post(url, body: {
      'produk': encodeMap,
    });

    _productController.allProduct.value = await loadProducts();
  }

  static Future<void> deleteProduct(List<String> key) async {
    final uri = Uri.parse('$domain/produk/delete.php');
    final encode = jsonEncode(key);
    http.post(uri, body: {'tabel': 'produk', 'list_kode': encode});
    _productController.allProduct.value = await loadProducts();
  }
}

mixin class SnackHelper {
  static final hasShow = false.obs;
  static Future<void> snackError(
      {String title = 'Error', required String content}) async {
    await Future.delayed(Duration(seconds: 1));

    if (!hasShow.value) {
      hasShow.value = true;

      Get.snackbar(title, content,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
      await Future.delayed(Duration(seconds: 3));
      hasShow.value = false;
    }
  }

  static Future<void> snackSucces(
      {String title = 'Error', required String content}) async {
    if (!hasShow.value) {
      hasShow.value = true;

      Get.snackbar(title, content,
          colorText: Colors.white,
          backgroundColor: Colors.purple,
          snackPosition: SnackPosition.BOTTOM);
    }
    await Future.delayed(const Duration(seconds: 3));
    hasShow.value = false;
  }
}
