import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:android_id/android_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/home/my_app.dart';

import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:myapp/controller/biometrik.dart';

final domain = 'http://10.88.0.3:8080';

class SplashController extends GetxController {
  final box = GetStorage();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordTersembunyi = true.obs;

  final token = ''.obs;
  final username = ''.obs;
  final deviceId = ''.obs;

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
      deviceId.value = box.read('deviceId') ?? '';
      final url = Uri.parse('$domain/token.php');
      if (token.value == '' || username.value == '' || deviceId.value == '') {
        isLoading.value = false;
        return;
      }
      final response = await http.post(url, body: {
        'username': username.value,
        'token': token.value,
        'device_id': deviceId.value
      });
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
      debugPrint('error token login $e');
      isLoading.value = false;
    }
  }

  Future<void> loginUser() async {
    isLoading.value = true;

    try {
      final url = Uri.parse('$domain/login.php');
      final deviceId = await generateDeviceId();
      final response = await http.post(url, body: {
        'username': usernameController.text,
        'password': passwordController.text,
        'device_id': deviceId,
      });
      final data = jsonDecode(response.body);

      if (data['status'] == 'sukses') {
        print(data);
        box.write('username', usernameController.text);
        box.write('token', data['token']);
        box.write('deviceId', data['device_id']);

        username.value = box.read('username');
        Get.snackbar('Berhasil', data['message'],
            colorText: Colors.white,
            backgroundColor: Colors.purple,
            snackPosition: SnackPosition.BOTTOM);
        initAllController();
        Get.offAll(() => MyApp());
      } else {
        print(data);
        Get.snackbar('Error', '${data['message']}',
            colorText: Colors.white,
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('error $e');
      Get.snackbar('Error', '$e',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  void initAllController() {
    Get.put(BiometrikController());

    Get.put(ProductController());

    Get.put(LaporanController());
    Get.put(KeranjangController());

    Get.put(QRScannerController());

    Get.put(TransaksiController());

    Get.put(ManagerController());
  }

  Future<String> generateDeviceId() async {
    if (kIsWeb) {
      return generateRandom();
    } else {
      final android = AndroidId();
      final id = await android.getId();
      print('id $id');
      return id ?? generateRandom();
    }
  }

  String generateRandom() {
    final random = Random();
    final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final ran = String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    final date = DateTime.now().millisecondsSinceEpoch.toString();
    return ran + date;
  }
}
