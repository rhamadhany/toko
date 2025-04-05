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

  final keyTransaksi = ''.obs;
  @override
  void onInit() {
    super.onInit();
    loadDatabase();
  }

  Future<void> loadDatabase() async {
    try {
      final uri = Uri.parse('$domain/load');
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
      int omset, int laba, int diskon) async {
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
          'laba': laba,
          'diskon': diskon
        }
      ]);

      final uri = Uri.parse('$domain/tambah');

      await http.post(uri, body: {'tabel': 'transaksi', 'produk': map});
    } catch (e) {
      Get.snackbar('Error', 'Failed add transaksi $e',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
    await loadDatabase();
  }
}
