import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/beranda_toko.dart';
import 'package:myapp/controller/product_controller.dart';

import 'package:sqflite/sqflite.dart';

class KeranjangController extends GetxController {
  Database? database;
  final RxList<Map<String, dynamic>> keranjangProduk =
      <Map<String, dynamic>>[].obs;
  final hasSnackbar = false.obs;

  final ProductController _productController = Get.find();
  final RxList<TextEditingController> jumlahControllers =
      RxList<TextEditingController>();
  final RxList<bool> valueBox = RxList<bool>();
  final boxAll = false.obs;
  final hargaJual = [];
  final isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    keranjangProdukListener();

    inisiasiDatabase();
  }

  Future<void> inisiasiDatabase() async {
    final rootPath = await getDatabasesPath();
    final dbPath = '$rootPath/keranjang.db';
    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE keranjang (
  key TEXT,
  produk TEXT,
  jumlah INTEGER,
  gambar TEXT
)
''');
      },
    );
    await loadProduk();
  }

  void keranjangProdukListener() {
    keranjangProduk.listen((_) async {
      // await initValueBox();
      update();
    });

    valueBox.listen((_) {
      if (valueBox.any((box) => box == false)) {
        boxAll.value = false;
      } else if (valueBox.every((box) => box == true)) {
        boxAll.value = true;
      }
    });
  }

  Future<void> initValueBox() async {
    isLoading.value = true;
    hargaJual.clear();

    // Load produk before manipulating lists to avoid inconsistencies
    await loadProduk();

    // Use a more efficient approach to update lists
    final keranjangLength = keranjangProduk.length;
    // final valueBoxLength = valueBox.length;
    // final jumlahControllersLength = jumlahControllers.length;

    // if (keranjangLength != valueBoxLength) {
    valueBox.clear();
    jumlahControllers.clear();
    valueBox.addAll(List.generate(keranjangLength, (_) => false));
    // }

    // if (keranjangLength != jumlahControllersLength) {
    jumlahControllers.clear();
    jumlahControllers.addAll(List.generate(keranjangLength, (index) {
      return TextEditingController(
          text: keranjangProduk[index]['jumlah'].toString());
    }));
    // }

    hargaJual.clear(); // Clear before adding new values
    hargaJual.addAll(List.generate(keranjangLength, (index) {
      final product = _productController.allProduct.firstWhere(
          (produk) => produk['key'] == keranjangProduk[index]['key'],
          orElse: () => {}); // Handle case where product is not found
      return product['harga_jual'] ?? 0; // Handle case where harga_jual is null
    }));

    // print(hargaJual);

    isLoading.value = false;
  }

  Future<void> loadProduk() async {
    const query = 'SELECT * FROM keranjang';
    await database!.rawQuery(query).then((result) {
      keranjangProduk.value =
          result.map((e) => e as Map<String, dynamic>).toList();
    });
    // update();
  }

  Future<void> addProduk(key, produk, jumlah, gambar) async {
    final indexKeys = keranjangProduk.indexWhere((pro) => pro['key'] == key);
    // print("indexKeys: $indexKeys");
    if (indexKeys != -1) {
      final updateKey = keranjangProduk[indexKeys]['key'];
      final jumlahBaru = keranjangProduk[indexKeys]['jumlah'] + jumlah;
      // print('jumlah baru: $jumlahBaru');
      await updateJumlah(updateKey, jumlahBaru);
    } else {
      const query =
          'INSERT INTO keranjang (key, produk, jumlah, gambar) VALUES (?, ?, ?, ?)';
      await database!.rawInsert(query, [key, produk, jumlah, gambar]);
    }
    // await loadProduk();
    await initValueBox();
  }

  Future<void> removeProduk(String key) async {
    const query = 'DELETE FROM keranjang WHERE key = ?';
    await database!.rawDelete(query, [key]);
  }

  void refreshProduk() {
    loadProduk();
  }

  Future<void> updateJumlah(String key, int jumlahUpdate) async {
    final index = indexKey(key);

    if (index != -1) {
      final stok = _productController.allProduct[index]['stok'];
      final terjual = _productController.allProduct[index]['terjual'];
      final produk = _productController.allProduct[index]['produk'];
      final sisa = stok - terjual;

      if (jumlahUpdate > sisa) {
        jumlahUpdate = sisa;
        if (!hasSnackbar.value) {
          hasSnackbar.value = true;
          Get.snackbar(
            "Stok",
            "$produk hanya tersisa $sisa",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red,
          );
          await Future.delayed(const Duration(seconds: 3));
          hasSnackbar.value = false;
        }
      }

      const query = 'UPDATE keranjang SET jumlah = ? WHERE key = ?';
      await database!.rawUpdate(query, [jumlahUpdate, key]);
      await loadProduk();
    }
  }

  int indexKey(String key) {
    return _productController.allProduct.indexWhere((pro) => pro['key'] == key);
  }

  int sisaPadaAllProduk(String key) {
    int sisa = -1;
    final indexkey = _productController.allProduct
        .indexWhere((produk) => produk['key'] == key);
    if (indexkey != -1) {
      final stok = _productController.allProduct[indexkey]['stok'];
      final terjual = _productController.allProduct[indexkey]['terjual'];
      sisa = stok - terjual;
    }
    return sisa;
  }

  Future<void> langsungtambahkeKeranjang(
      int sisa, RxMap<String, dynamic> produkBaru) async {
    if (sisa > 0) {
      final gambar =
          produkBaru['gambar'].isEmpty ? "" : produkBaru['gambar'][0];
      await addProduk(produkBaru['key'], produkBaru['produk'], 1, gambar);

      Get.back();
      HomeToko.focusPencarian.unfocus();

      Get.snackbar(
          "Keranjang", '${produkBaru['produk']} ditambahkan ke keranjang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1));
    } else {
      Get.snackbar("Stok", "${produkBaru['produk']} kosong",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 1));
    }
  }
}
