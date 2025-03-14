import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class ManagerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  final tabIndex = 0.obs;
  // bool canPop = true;
  final skalaAnimation = 1.0.obs;

  final ProductController _productController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabListener();
  }

  Future<void> inisiasiAuthController() async {
    if (Settings.autentikasiAktif.value) {
      _biometrikController.hasAuthenticated.value = false;

      _biometrikController.hasAuthenticated.value =
          await _biometrikController.authReuired();
    }
  }

  void tabListener() {
    tabController?.addListener(() async {
      tabIndex.value = tabController!.index;
      await inisiasiAuthController();
      if (_productController.showCheckBoxRemove.value &&
          tabController?.index != 0) {
        _productController.showCheckBoxRemove.value = false;
      }
      if (tabController!.indexIsChanging) {
        for (int i = 0; i < 60; i++) {
          if (i < 30) {
            skalaAnimation.value -= 0.01;
          } else {
            skalaAnimation.value += 0.01;
          }
          await Future.delayed(Duration(milliseconds: 10));
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    tabController?.removeListener(() {});
    tabController?.dispose();
  }

  Future<bool> confirmationDelete() async {
    final bool? confirm = await Get.dialog<bool?>(AlertDialog(
      title: const Text("Konfirmasi"),
      content: const Text("Anda yakin untuk menghapus produk ini?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text("Ya")),
      ],
    ));
    return confirm ?? false;
  }
}
