import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final ProductController _productController =
      Get.find<ProductController>();

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
      RxList<dynamic> pictures) async {
    final db = _productController.database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    _productController.allProduct.value = await loadProducts();
    final jsonPictures = jsonEncode(pictures);
    final time = DateTime.now();
    final random = Random();
    int randomNumber = random.nextInt(1000) + 1;

    // String key = base64Encode(utf8.encode(now.toString()));
    final keyString =
        'ID${time}_${_productController.allProduct.length + 1}_$randomNumber';
    final key = base64Encode(utf8.encode(keyString));

    await db.insert('products', {
      'key': key,
      'produk': product,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'terjual': terjual,
      'stok': stock,
      'gambar': jsonPictures,
    });
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
