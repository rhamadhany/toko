import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/db_helper.dart';
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
        if (!await DBHelper.columnExists(db, 'products', 'harga_beli')) {
          await db.execute('ALTER TABLE products ADD COLUMN harga_beli TEXT');
        }
        if (!await DBHelper.columnExists(db, 'products', 'harga_jual')) {
          await db.execute('ALTER TABLE products ADD COLUMN harga_jual TEXT');
        }
      }
    });

    allProduct.value = await DBHelper.loadProducts();

    if (allProduct.isEmpty) {}
  }
}
