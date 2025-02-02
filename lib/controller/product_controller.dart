import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ProductController extends GetxController {
  Rx<Database?> database = Rx<Database?>(null);

  final showCheckBoxRemove = false.obs;
  final RxList<Map<dynamic, String>> mapCheckBoxRemove =
      <Map<dynamic, String>>[].obs;
  final RxInt bottomIndex = 0.obs;
  final jualController = TextEditingController(text: '0').obs;
  final pencarianController = TextEditingController();
  final daftarKategori = ['Semua', 'TV', 'kulkas', 'dinamo'].obs;
  final kategoriTerpilih = 'Semua'.obs;
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
    // allProductListener();
    loadDaftarKategori();
    pencarianController.addListener(() {
      // update();
      // filteringProduk();
      searchText.value = pencarianController.text;
    });
  }

  Future<void> saveDaftarKategori() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('kategori', daftarKategori);
    });
  }

  Future<void> loadDaftarKategori() async {
    await SharedPreferences.getInstance().then((prefs) {
      daftarKategori.value = prefs.getStringList('kategori') ?? ['Semua'];
    });
  }

  void filteringProduk() {
    filterProduct.value = allProduct;
    searchText.listen((data) {
      filterProduct.value = allProduct
          .where((produk) =>
              produk['produk'].toLowerCase().contains(data.toLowerCase()) ||
              produk['key'] == data)
          .toList();
      generateMapCheckBox();
    });
    allProduct.listen((_) {
      filterProduct.value = allProduct
          .where((produk) =>
              produk['produk']
                  .toLowerCase()
                  .contains(searchText.value.toLowerCase()) ||
              produk['key'] == searchText.value)
          .toList();
      filterProduct.refresh();
      update();
      generateMapCheckBox();
    });
  }

  String hargaProduk(RxMap<String, dynamic> produk) {
    final hargaProduk = produk['harga_jual'].toString();
    final hargaJual = regexNominal(hargaProduk);

    return hargaJual.trim() == "" ? "0" : hargaJual;
  }

  String regexNominal(String value) {
    return value.replaceAll(".", "").replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
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
    database.value = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE products
          (
            key TEXT,
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

    allProduct.value = await DBHelper.loadProducts();

    if (allProduct.isEmpty) {}
  }
}
