import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';

import 'package:sqflite/sqflite.dart';

class KeranjangController extends GetxController {
  Database? database;
  final RxList<Map<String, dynamic>> keranjangProduk =
      <Map<String, dynamic>>[].obs;
  final hasSnackbar = false.obs;

  final ProductController _productController = Get.find();

  @override
  void onInit() {
    super.onInit();
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
      await loadProduk();
    }
  }

  Future<void> removeProduk(String key) async {
    const query = 'DELETE FROM keranjang WHERE key = ?';
    await database!.rawDelete(query, [key]);
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
          Get.snackbar("Stok", "$produk hanya tersisa $sisa",
              snackPosition: SnackPosition.BOTTOM);
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
}
