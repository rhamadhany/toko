import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final ProductController _productController =
      Get.find<ProductController>();
  static final LaporanController _laporanController = Get.find();

  static Future<bool> columnExists(
      Database db, String tableName, String columnName) async {
    final List<Map<String, dynamic>> result =
        await db.rawQuery('PRAGMA table_info($tableName)');
    for (var column in result) {
      if (column['name'] == columnName) {
        return true; // Kolom ada
      }
    }
    return false; // Kolom tidak ada
  }

  static Future<List<Map<String, dynamic>>> loadProducts() async {
    final db = _productController.database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    final result = await db.query('products');
    final processedResult = result.map((row) {
      final newRow = Map<String, dynamic>.from(row);
      try {
        newRow['gambar'] = jsonDecode(row['gambar'].toString());
      } catch (e) {
        newRow['gambar'] = "";
      }
      return newRow;
    }).toList();
    return processedResult;
  }

  static Future<void> addProduct(
      String product,
      String hargaBeli,
      String hargaJual,
      int terjual,
      int stock,
      RxList<dynamic> pictures,
      String kategori,
      String deskripsi) async {
    final db = _productController.database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    _productController.allProduct.value = await loadProducts();
    final jsonPictures = jsonEncode(pictures);

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

    await db.insert('products', {
      'key': key,
      'produk': product,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'terjual': terjual,
      'stok': stock,
      'gambar': jsonPictures,
      'kategori': kategori,
      'deskripsi': deskripsi,
    });
    await _laporanController.database?.insert('penambahan', {
      'key': key,
      'tanggal': DateTime.now().toString(),
      'produk': product,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'terjual': terjual,
      'stok': stock,
      'gambar': jsonPictures,
      'kategori': kategori,
      'deskripsi': deskripsi
    });
    await _laporanController.loadProduk();
    _productController.allProduct.value = await loadProducts();
  }

  static Future updateTerjual(String key, int terjual) async {
    final db = _productController.database.value;
    if (db != null) {
      const queryBaca = 'SELECT terjual FROM products WHERE key = ?';
      final result = await db.rawQuery(queryBaca, [key]);
      final int terjualSebelumnya = (result.first['terjual'] as int?) ?? 0;

      final int updateTerjual = terjualSebelumnya + terjual;
      const query = 'UPDATE products SET terjual = ? WHERE key = ?';
      await db.rawUpdate(query, [updateTerjual, key]);
      _productController.allProduct.value = await loadProducts();
    }
  }

  static Future updateProduct(RxMap<String, dynamic> produk) async {
    final db = _productController.database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final gambarJson = jsonEncode(produk['gambar']);

    final query = 'SELECT * FROM products WHERE key = ?';
    final old = await db.rawQuery(query, [produk['key']]);

    if (old.isEmpty) {
      return {};
    }

    final oldProduk = old.first;

    // print(old);
    final tanggal = DateTime.now().toString();
    await _laporanController.database?.insert('perubahan', {
      'key': produk['key'],
      'tanggal': tanggal,
      'produk_baru': produk['produk'],
      'produk_lama': oldProduk['produk'],
      'harga_beli_baru': produk['harga_beli'],
      'harga_beli_lama': oldProduk['harga_beli'],
      'harga_jual_baru': produk['harga_jual'],
      'harga_jual_lama': oldProduk['harga_jual'],
      'terjual_baru': produk['terjual'],
      'terjual_lama': oldProduk['terjual'],
      'stok_baru': produk['stok'],
      'stok_lama': oldProduk['stok'],
      'gambar_baru': gambarJson,
      'gambar_lama': oldProduk['gambar'],
      'kategori_baru': produk['kategori'],
      'kategori_lama': oldProduk['kategori'],
      'deskripsi_baru': produk['deskripsi'],
      'deskripsi_lama': oldProduk['deskripsi']
    });
    await _laporanController.loadProduk();
    await db.update(
      'products',
      {
        ...produk,
        'gambar': gambarJson,
      },
      where: 'key = ?',
      whereArgs: [produk['key']],
    );
    _productController.allProduct.value = await loadProducts();
  }

  static Future<void> deleteProduct(List<String> key) async {
    final db = _productController.database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    for (var id in key) {
      await db.delete('products', where: 'key = ?', whereArgs: [id]);
    }

    _productController.allProduct.value = await loadProducts();
  }
}
