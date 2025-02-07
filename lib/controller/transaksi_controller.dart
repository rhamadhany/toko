import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class TransaksiController extends GetxController {
  final transaksiMap = [{}].obs;
  Database? dbT;
  // final tanggalTransaksi = DateTime.now().toString().split('.')[0].obs;
  final keyTransaksi = ''.obs;
  @override
  void onInit() {
    super.onInit();
    inisiasiDatabase();
  }

  Future<void> inisiasiDatabase() async {
    final rootPath = await getDatabasesPath();
    final dbPath = '$rootPath/transaksi.db';

    dbT = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE transaksi (
tanggal TEXT,
key TEXT,
keyProduk TEXT,
jumlah INTEGER,
modal INTEGER,
omset INTEGER,
laba INTEGER
)
''');
      },
    );
    await loadDatabase();
  }

  Future<void> loadDatabase() async {
    final queryDB = 'SELECT * FROM transaksi';
    await dbT?.rawQuery(queryDB).then((result) {
      transaksiMap.value = result;
    });
  }

  Future<void> addTransaksi(int jumlah, List<String> keyProduk, int modal,
      int omset, int laba) async {
    final tanggal = DateTime.now().toString();
    final second = DateTime.now().second;
    final random = Random();
    final number = random.nextInt(1000);

    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rString = String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    final encode = base64Encode(utf8.encode('$second$number$rString'));

    await dbT?.insert('transaksi', {
      'tanggal': tanggal,
      'key': encode,
      'keyProduk': jsonEncode(keyProduk),
      'jumlah': jumlah,
      'modal': modal,
      'omset': omset,
      'laba': laba
    });

    await loadDatabase();
  }
}
