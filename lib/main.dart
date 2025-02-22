import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/home/splash_login.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/main_controller.dart';
import 'package:myapp/controller/product_controller.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Memastikan binding diinisialisasi
  await GetStorage.init(); // Inisialisasi GetStorage

  // Inisialisasi controller menggunakan Get.putAsync
  await Get.putAsync(() async {
    // SplashController
    final splashController = SplashController();
    return splashController;
  });
  await Get.putAsync(() async {
    // BiometrikController
    final biometrikController = BiometrikController();
    return biometrikController;
  });
  await Get.putAsync(() async {
    // ProductController
    final productController = ProductController();
    return productController;
  });
  await Get.putAsync(() async {
    // LaporanController
    final laporanController = LaporanController();
    return laporanController;
  });
  await Get.putAsync(() async {
    // KeranjangController
    final keranjangController = KeranjangController();
    return keranjangController;
  });
  await Get.putAsync(() async {
    // MainController
    final mainController = MainController();
    return mainController;
  });
  await Get.putAsync(() async {
    // QRScannerController
    final qRScannerController = QRScannerController();
    return qRScannerController;
  });
  await Get.putAsync(() async {
    // TransaksiController
    final transaksiController = TransaksiController();
    return transaksiController;
  });

  runApp(
    GetMaterialApp(
      home: SplashLogin(),
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
    ),
  );
}
