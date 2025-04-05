import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/splash_login.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:http/http.dart' as http;

class ManagerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final tabIndex = 0.obs;

  final skalaAnimation = 1.0.obs;

  final box = GetStorage();
  final BiometrikController _biometrikController = Get.find();

  final userName = ''.obs;

  @override
  void onInit() {
    DialogJualHelper.selectedGrosir.value = box.read('selectedGrosir') ?? {};
  }

  Future<void> inisiasiAuthController() async {
    if (Settings.autentikasiAktif.value) {
      _biometrikController.hasAuthenticated.value = false;

      _biometrikController.hasAuthenticated.value =
          await _biometrikController.authReuired();
    }
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
    _biometrikController.hasAuthenticated.value = false;
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
    final deviceId = Get.find<SplashController>().deviceId.value == ''
        ? await Get.find<SplashController>().generateDeviceId()
        : Get.find<SplashController>().deviceId.value;
    final url = Uri.parse('$domain/login');
    final response = await http.post(url, body: {
      'username': userName.value,
      'password': value,
      'device_id': deviceId
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'sukses') {
        Get.back();
        _biometrikController.hasAuthenticated.value = true;
        box.write('token', data['token']);
      } else {
        SnackHelper.snackError(content: data['message']);
      }
    }
  }
}
