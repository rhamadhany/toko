import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class TransaksiController extends GetxController {
  final transaksiMap = [{}].obs;
  Database? dbT;
  // final tanggalTransaksi = DateTime.now().toString().split('.')[0].obs;
  final keyTransaksi = ''.obs;
  @override
  void onInit() {
    super.onInit();
    loadDatabase();
    // inisiasiDatabase();
  }

//   Future<void> inisiasiDatabase() async {
//     final rootPath = await getDatabasesPath();
//     final dbPath = '$rootPath/transaksi.db';

//     dbT = await openDatabase(
//       dbPath,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
// CREATE TABLE transaksi (
// tanggal TEXT,
// key TEXT,
// keyProduk TEXT,
// jumlah INTEGER,
// modal INTEGER,
// omset INTEGER,
// laba INTEGER
// )
// ''');
//       },
//     );
//     await loadDatabase();
//   }

  Future<void> loadDatabase() async {
    // final queryDB = 'SELECT * FROM transaksi';
    // await dbT?.rawQuery(queryDB).then((result) {
    //   transaksiMap.value = result;
    // });
    try {
      final uri = Uri.parse('$domain/produk/load.php');
      final response = await http.post(uri, body: {'tabel': 'transaksi'});
      if (response.statusCode == 200) {
        final decode = jsonDecode(response.body);
        transaksiMap.value = List<Map<String, dynamic>>.from(decode);
      }
    } catch (e) {
      Get.snackbar('Error', 'Load db transaksi controller $e',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addTransaksi(int jumlah, List<String> keyProduk, int modal,
      int omset, int laba) async {
    try {
      final tanggal = DateTime.now().toString();
      final second = DateTime.now().second;
      final random = Random();
      final number = random.nextInt(1000);

      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rString = String.fromCharCodes(Iterable.generate(
          8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
      final encode = base64Encode(utf8.encode('$second$number$rString'));
      final map = jsonEncode([
        {
          'tanggal': tanggal,
          'kode_transaksi': encode,
          'kode_produk': jsonEncode(keyProduk),
          'jumlah': jumlah,
          'modal': modal,
          'omset': omset,
          'laba': laba
        }
      ]);

      final uri = Uri.parse('$domain/produk/tambah.php');
      // final response =
      await http.post(uri, body: {'tabel': 'transaksi', 'produk': map});
      // if (response.statusCode == 200) {

      // }
      // await dbT?.insert('transaksi', {
      //   'tanggal': tanggal,
      //   'kode_produk: encode,
      //   'keyProduk': jsonEncode(keyProduk),
      //   'jumlah': jumlah,
      //   'modal': modal,
      //   'omset': omset,
      //   'laba': laba
      // });
    } catch (e) {
      Get.snackbar('Error', 'Failed add transaksi $e',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
    await loadDatabase();
  }
}
