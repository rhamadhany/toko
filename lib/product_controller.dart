import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class ProductController extends GetxController {
  Rx<Database?> database = Rx<Database?>(null);

  final showCheckBoxRemove = false.obs;
  final RxList<Map<dynamic, String>> mapCheckBoxRemove =
      <Map<dynamic, String>>[].obs;
  final RxInt bottomIndex = 0.obs;
  final jualController = TextEditingController(text: '0').obs;

  final searchText = "".obs;
  final RxList<Map<String, dynamic>> listTextField =
      RxList<Map<String, dynamic>>([
    {'label': 'Nama Produk', 'controller': TextEditingController()},
    {
      'label': 'Harga Beli',
      'controller': TextEditingController(),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Harga Jual',
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
  final RxList<Map<String, dynamic>> filterProduct =
      <Map<String, dynamic>>[].obs;
  final showSearch = false.obs;
  @override
  void onInit() {
    super.onInit();
    initDatabase();
    filteringProduk();
  }

  void filteringProduk() {
    filterProduct.value = allProduct;
    searchText.listen((data) {
      filterProduct.value = allProduct
          .where((produk) =>
              produk['produk'].toLowerCase().contains(data.toLowerCase()))
          .toList();
      generateMapCheckBox();
    });
    allProduct.listen((data) {
      filterProduct.value = allProduct
          .where((produk) => produk['produk']
              .toLowerCase()
              .contains(searchText.value.toLowerCase()))
          .toList();

      generateMapCheckBox();
    });
  }

  String hargaProduk(RxMap<String, dynamic> produk) {
    final hargaJual = produk['harga_jual']
        .toString()
        .replaceAll(".", "")
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return hargaJual.trim() == "" ? "0" : hargaJual;
  }

  Future generateMapCheckBox() async {
    if (filterProduct.isEmpty) {
      showCheckBoxRemove.value = false;
      mapCheckBoxRemove.clear();
    } else {
      mapCheckBoxRemove.value = List.generate(
          filterProduct.length,
          (index) =>
              {'isSelected': 'false', 'key': filterProduct[index]['key']});
    }
  }

  Future<void> initDatabase() async {
    final pathDatabase = await getDatabasesPath();
    final path = '$pathDatabase/product_database.db';
    database.value =
        await openDatabase(path, version: 2, onCreate: (db, version) async {
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
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        if (!await columnExists(db, 'products', 'harga_beli')) {
          await db.execute('ALTER TABLE products ADD COLUMN harga_beli TEXT');
        }
        if (!await columnExists(db, 'products', 'harga_jual')) {
          await db.execute('ALTER TABLE products ADD COLUMN harga_jual TEXT');
        }
      }
    });

    allProduct.value = await loadProducts();

    if (allProduct.isEmpty) {}
  }

  Future<bool> columnExists(
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

  Future<void> addProduct(String product, String hargaBeli, String hargaJual,
      int terjual, int stock, RxList<dynamic> pictures) async {
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
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
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
