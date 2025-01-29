import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/biometrik.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/settings.dart';
// import 'package:myapp/settings.dart';

class MainController extends GetxController with GetTickerProviderStateMixin {
  final ProductController _productController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  @override
  void onInit() {
    super.onInit();
    _biometrikController.tabController = TabController(length: 4, vsync: this);
    tabListener();
  }

  void tabListener() {
    _biometrikController.tabController?.addListener(() async {
      _biometrikController.hasAuthenticated.value = false;
      _biometrikController.tabIndex.value =
          _biometrikController.tabController!.index;

      if (_biometrikController.tabController?.index != 0 &&
          _biometrikController.tabController?.index != 3 &&
          Settings.autentikasiAktif.value) {
        final hasAuth = await _biometrikController.authReuired();
        if (hasAuth) {
          _biometrikController.hasAuthenticated.value = true;
        }
      }

      if (_productController.showCheckBoxRemove.value &&
          _biometrikController.tabController?.index != 1) {
        _productController.showCheckBoxRemove.value = false;
      }

      update();
    });
  }

  @override
  void dispose() {
    _biometrikController.tabController?.dispose();
    super.dispose();
  }
}
