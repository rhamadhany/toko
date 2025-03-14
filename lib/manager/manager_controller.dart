import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManagerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  final tabIndex = 0.obs;
  // bool canPop = true;
  final skalaAnimation = 1.0.obs;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabListener();
  }

  void tabListener() {
    tabController?.addListener(() async {
      tabIndex.value = tabController!.index;
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
