// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/pengaturan/settings.dart';
// import 'package:myapp/settings.dart';

class MainController extends GetxController with GetTickerProviderStateMixin {
  final ProductController _productController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final skalaAnimation = 1.0.obs;
  // late Animation<double> animation;
  final animation = 0.0.obs;
  TabController? tabController;
  final tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
        length: 2, vsync: this, animationDuration: Duration(milliseconds: 0));

    tabListener();
  }

  void tabListener() {
    tabController?.addListener(() async {
      _biometrikController.hasAuthenticated.value = false;
      tabIndex.value = tabController!.index;

      if (tabController?.index == 1 && Settings.autentikasiAktif.value) {
        final hasAuth = await _biometrikController.authReuired();
        if (hasAuth) {
          _biometrikController.hasAuthenticated.value = true;
        }
      }

      if (_productController.showCheckBoxRemove.value &&
          tabController?.index != 1) {
        _productController.showCheckBoxRemove.value = false;
      }
      // tabController!.animateTo(1, curve: Curves.bounceOut, duration: Duratio)
      // skalaAnimation.value = 0.5;
      // await Future.delayed(Duration(milliseconds: ));
      // skalaAnimation.value = 1;
      // Timer.periodic(Duration(milliseconds: 100), (_) {
      //   if (skalaAnimation.value > 0.5) {
      //     skalaAnimation.value -= 0.1;
      //   } else {
      //     _.cancel();
      //   }
      // });
      // if (tabController!.indexIsChanging) {

      // }

      // ignore: curly_braces_in_flow_control_structures

      // while (skalaAnimation.value != 0.5) {
      //   await Future.delayed(Duration(milliseconds: 100));
      // }
      // Timer.periodic(Duration(milliseconds: 100), (_) {
      //   if (skalaAnimation.value < 1) {
      //     skalaAnimation.value += 0.1;
      //   } else {
      //     _.cancel();
      //   }
      // });
      update();
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
