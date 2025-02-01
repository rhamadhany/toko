import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:sqflite/sqflite.dart';

class LaporanController extends GetxController {
  Database? database;
  final RxList<Map<String, dynamic>> penjualan = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> perubahan = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> penambahan = <Map<String, dynamic>>[].obs;
  final viewMode = 'Hari'.obs;
  final ProductController _productController = Get.find();
  final bulanTerpilih = ''.obs;
  final bulan = (DateTime.now().month - 1).obs;
  final tahunTerpilih = DateTime.now().year.obs;
  List<String> namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void onInit() {
    super.onInit();
    bulanTerpilih.value = namaBulan[bulan.value];
    inisiasiDatabase();
    // bulanListener();
  }

  void bulanListener() {
    bulanTerpilih.listen((_) {
      refresh();
    });
  }

  Future<void> inisiasiDatabase() async {
    final rootPath = await getDatabasesPath();
    final dbPath = '$rootPath/laporan.db';
    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE perubahan (
  key TEXT,
  tanggal TEXT,
  produk TEXT,
  lama TEXT,
  baru TEXT
  
)
''');

        await db.execute('''
CREATE TABLE penjualan (
  key TEXT,
  tanggal TEXT,
  produk TEXT,
  jumlah INTEGER,
  harga_beli TEXT,
  harga_jual TEXT
  
  
)
''');

        await db.execute('''
CREATE TABLE penambahan (
            key TEXT,
            tanggal TEXT,
            produk TEXT,
            harga_beli TEXT,
            harga_jual TEXT,
            terjual INTEGER,
            stok INTEGER,
            gambar TEXT
)
''');
      },
    );
    await loadProduk();
  }

  Future<void> loadProduk() async {
    final list = ['perubahan', 'penjualan', 'penambahan'];

    for (final table in list) {
      try {
        final query = 'SELECT * FROM $table';
        final result = await database!.rawQuery(query);
        final data = result.map((e) => e as Map<String, dynamic>).toList();

        switch (table) {
          case 'perubahan':
            perubahan.value = data;
            break;
          case 'penjualan':
            penjualan.value = data;
            // print(penjualan);
            break;
          case 'penambahan':
            penambahan.value = data;
            break;
        }
      } catch (e) {
        // Penanganan kesalahan
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> tambahJual(String key, int jumlah, String table) async {
    final indexKey = _productController.allProduct
        .indexWhere((produk) => produk['key'] == key);
    if (indexKey != -1) {
      final date = DateTime.now();
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
      // print(formattedDate);

      // print(formattedDate)

      final values = {
        'key': key,
        'tanggal': formattedDate,
        'produk': _productController.allProduct[indexKey]['produk'],
        'jumlah': jumlah,
        'harga_beli': _productController.allProduct[indexKey]['harga_beli'],
        'harga_jual': _productController.allProduct[indexKey]['harga_jual'],
      };

      await database!.insert(
        table,
        values,
      );
      await loadProduk();
    }
  }
}
