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
  await GetStorage.init();
  Get.put(SplashController());
  Get.put(BiometrikController());
  Get.put(ProductController());
  Get.put(LaporanController());

  Get.put(KeranjangController());
  Get.put(MainController());

  Get.put(QRScannerController());
  Get.put(TransaksiController());

  runApp(GetMaterialApp(
    home: SplashLogin(),
    theme: ThemeData(),
    darkTheme: ThemeData.dark(),
  ));
}
