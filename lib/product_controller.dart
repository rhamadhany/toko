import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class ProductController extends GetxController {
  Rx<Database?> database = Rx<Database?>(null);

  final loadingProduct = true.obs;
  final showCheckBoxRemove = false.obs;
  final RxList<Map<dynamic, String>> mapCheckBoxRemove =
      <Map<dynamic, String>>[].obs;
  final RxInt bottomIndex = 0.obs;
  final jualController = TextEditingController(text: '0').obs;
  final RxList<Map<String, dynamic>> listTextField =
      RxList<Map<String, dynamic>>([
    {'label': 'Nama Produk', 'controller': TextEditingController()},
    {
      'label': 'Harga',
      'controller': TextEditingController(),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Terjual',
      'controller': TextEditingController(text: "0"),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Stok',
      'controller': TextEditingController(),
      'keyboardType': TextInputType.number
    },
  ]);
  final RxList<Map<String, dynamic>> allProduct = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initDatabase();
  }

  String hargaProduk(RxMap<String, dynamic> produk) {
    final harga = produk['harga']
        .toString()
        .replaceAll(".", "")
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    // print('harga $harga');
    return harga.trim() == "" ? "0" : harga;
  }

  Future generateMapCheckBox() async {
    if (allProduct.isEmpty) {
      showCheckBoxRemove.value = false;
      mapCheckBoxRemove.clear();
    } else {
      mapCheckBoxRemove.value = List.generate(allProduct.length,
          (index) => {'isSelected': 'false', 'key': allProduct[index]['key']});
    }
  }

  Future<void> initDatabase() async {
    loadingProduct.value = true;
    final pathDatabase = await getDatabasesPath();
    final path = '$pathDatabase/product_database.db';
    database.value =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''CREATE TABLE products
          (
            key TEXT,
            produk TEXT,
            harga TEXT,
            terjual INTEGER,
            stok INTEGER,
            gambar TEXT
          )
          ''');
    }, onUpgrade: (db, oldVersion, newVersion) {});

    allProduct.value = await loadProducts();
    loadingProduct.value = false;
    if (allProduct.isEmpty) {}
  }

  Future<List<Map<String, dynamic>>> loadProducts() async {
    final db = database.value;
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

  Future<void> addProduct(String product, String harga, int terjual, int stock,
      RxList<dynamic> pictures) async {
    final db = database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    final jsonPictures = jsonEncode(pictures);
    DateTime now = DateTime.now();
    String key = base64Encode(utf8.encode(now.toString()));
    await db.insert('products', {
      'key': key,
      'produk': product,
      'harga': harga,
      'terjual': terjual,
      'stok': stock,
      'gambar': jsonPictures,
    });
    allProduct.value = await loadProducts();
  }

  Future updateProduct(RxMap<String, dynamic> produk) async {
    final db = database.value;
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
    allProduct.value = await loadProducts();
  }

  Future<void> deleteProduct(List<String> key) async {
    final db = database.value;
    if (db == null) {
      throw Exception('Database not initialized');
    }
    for (var id in key) {
      await db.delete('products', where: 'key = ?', whereArgs: [id]);
    }

    allProduct.value = await loadProducts();
  }
}
