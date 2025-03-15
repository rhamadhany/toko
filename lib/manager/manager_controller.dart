import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/splash_login.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:http/http.dart' as http;

class ManagerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  final tabIndex = 0.obs;
  // bool canPop = true;
  final skalaAnimation = 1.0.obs;

  final box = GetStorage();
  final ProductController _productController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final hasAuthenticated = false.obs;
  final userName = ''.obs;
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

  Future<void> requestPassword() async {
    hasAuthenticated.value = false;
    userName.value = box.read('username');
    await Future.delayed(Duration(seconds: 1));
    Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.blue)),
          content: IntrinsicHeight(
            child: Column(
              children: [
                RichText(
                    text: TextSpan(
                        style: TextStyle(
                            color: Get.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16),
                        children: [
                      TextSpan(text: 'Harap masukkan password untuk pengguna '),
                      TextSpan(
                          text: userName.value,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ])),
                // Text('Harap masukkan password untuk pengguna $username'),
                SizedBox(
                  height: 20,
                ),
                TextFormPassword(verifikasiPassword)
              ],
            ),
          ),
        ));
  }

  Future<void> verifikasiPassword(String value) async {
    // print(value);

    final url = Uri.parse('$domain/login.php');
    final response = await http
        .post(url, body: {'username': userName.value, 'password': value});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['status'] == 'sukses') {
        // Get.snackbar('Login', 'berhasil');
        Get.back();
        hasAuthenticated.value = true;
        box.write('token', data['token']);
      } else {
        SnackHelper.snackError(content: data['message']);
      }
    }
  }
}
