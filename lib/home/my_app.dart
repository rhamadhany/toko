import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/main_controller.dart';
import 'package:myapp/home/animasi_transisi_tab.dart';

import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/home/appbar_my_app.dart';

import 'package:myapp/pengaturan/settings.dart';

class MyApp extends GetView<MainController> {
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
        body: TabBarView(
            physics: controller.tabIndex.value == 2
                ? const NeverScrollableScrollPhysics()
                : null,
            controller: controller.tabController,
            children: [
              AnimasiTransisiTab(
                widgetChild: HomeToko(
                  isManager: false,
                ),
                skalaAnimation: controller.skalaAnimation,
              ),
              AnimasiTransisiTab(
                widgetChild: const Settings(),
                skalaAnimation: controller.skalaAnimation,
              )
            ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.blue),
          child: TabBar(
              onTap: (_) async {
                for (int i = 0; i < 60; i++) {
                  if (i < 30) {
                    controller.skalaAnimation.value -= 0.01;
                  } else {
                    controller.skalaAnimation.value += 0.01;
                  }
                  await Future.delayed(Duration(microseconds: 5000));
                }
              },
              labelColor: Colors.white,
              unselectedLabelColor: const Color.fromARGB(185, 255, 255, 255),
              controller: controller.tabController,
              tabs: [
                const Tab(text: "PRODUK", icon: Icon(Icons.shop)),
                Tab(
                  text: 'ADMIN',
                  icon: const Icon(Icons.admin_panel_settings),
                )
              ]),
        ),
      ),
    );
  }

  void dialogTutup(didPop, result) {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: const Text("Keluar"),
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
