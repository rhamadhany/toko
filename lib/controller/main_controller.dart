import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainController extends GetxController with GetTickerProviderStateMixin {
  TabController? tabController;
  final tabIndex = 0.obs;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabListener();
  }

  void tabListener() {
    tabController?.addListener(() {
      tabIndex.value = tabController!.index;
      update();
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }
}
