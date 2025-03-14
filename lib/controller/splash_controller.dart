import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/home/my_app.dart';

import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/main_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:myapp/manager/manager_toko.dart';
import 'package:myapp/pengaturan/biometrik.dart';

final domain = 'http://192.168.36.228:8080';

class SplashController extends GetxController {
  final box = GetStorage();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordTersembunyi = true.obs;

  final token = ''.obs;
  final username = ''.obs;

  final isConnected = false.obs;
  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    verifikasiToken();
  }

  Future<void> verifikasiToken() async {
    try {
      token.value = box.read('token') ?? '';
      username.value = box.read('username') ?? '';
      final url = Uri.parse('$domain/token.php');
      if (token.value == '' || username.value == '') {
        isLoading.value = false;
        return;
      }
      final response = await http
          .post(url, body: {'username': username.value, 'token': token.value});
      final data = jsonDecode(response.body);
      if (data['status'] == 'sukses') {
        initAllController();
        Get.offAll(() => MyApp(),
            transition: Transition.fade, duration: Duration(seconds: 1));
        await Future.delayed(const Duration(seconds: 1));
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> loginUser() async {
    try {
      final url = Uri.parse('$domain/login.php');
      final response = await http.post(url, body: {
        'username': usernameController.text,
        'password': passwordController.text,
      });
      final data = jsonDecode(response.body);

      if (data['status'] == 'sukses') {
        box.write('username', usernameController.text);

        box.write('token', data['token']);
        username.value = box.read('username');
        Get.snackbar('Berhasil', data['message'],
            colorText: Colors.white,
            backgroundColor: Colors.purple,
            snackPosition: SnackPosition.BOTTOM);
        initAllController();
        Get.offAll(() => MyApp());
      } else {
        Get.snackbar('Error', '${data['message']}',
            colorText: Colors.white,
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', '$e',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void initAllController() {
    Get.put(BiometrikController());

    Get.put(ProductController());

    Get.put(LaporanController());
    Get.put(KeranjangController());

    Get.put(MainController());
    Get.put(QRScannerController());

    Get.put(TransaksiController());

    Get.put(ManagerController());
  }
}
