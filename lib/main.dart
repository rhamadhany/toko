// import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/home/my_app.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/main_controller.dart';
import 'package:myapp/controller/product_controller.dart';

void main() {
  Get.put(BiometrikController());
  Get.put(ProductController());
  Get.put(LaporanController());

  Get.put(
      KeranjangController()); // Ini sudah permanen karena menggunakan Get.put
  Get.put(MainController());

  runApp(GetMaterialApp(
    home: MyApp(),
    theme: ThemeData(),
    darkTheme: ThemeData.dark(),
  ));
}
