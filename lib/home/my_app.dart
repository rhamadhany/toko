import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';

import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/home/appbar_my_app.dart';
import 'package:myapp/manager/manager_toko.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: dialogTutup,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: AppBarMyApp(
            isManager: false,
          ),
        ),
        body: HomeToko(
          isManager: false,
        ),
      ),
    );
  }

  void dialogTutup(didPop, result) {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue)),
        title: const Text(
          "Keluar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Keluar dari aplikasi?"),
        actions: [
          ElevatedButton(
              onPressed: () => Get.back(), child: const Text("Tidak")),
          ElevatedButton(onPressed: () => exit(0), child: const Text("Ya"))
        ],
      ),
    );
  }
}
