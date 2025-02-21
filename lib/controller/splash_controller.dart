import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/home/my_app.dart';

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
      token.value = await box.read('token');
      username.value = await box.read('username');
      final url = Uri.parse(
          'https://8080-idx-toko-1740067488955.cluster-a3grjzek65cxex762e4mwrzl46.cloudworkstations.dev/verifikasi.php');

      final response = await http
          .post(url, body: {'username': username.value, 'token': token.value});
      final data = jsonDecode(response.body);
      if (data['status'] == 'sukses') {
        Get.offAll(() => MyApp());
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> loginUser() async {
    final url = Uri.parse(
        'https://8080-idx-toko-1740067488955.cluster-a3grjzek65cxex762e4mwrzl46.cloudworkstations.dev/login.php');
    final response = await http.post(url, body: {
      'username': usernameController.text,
      'password': passwordController.text,
    });
    try {
      final data = jsonDecode(response.body);

      if (data['status'] == 'sukses') {
        box.write('username', usernameController.text);
        box.write('token', data['token']);
        username.value = box.read('username');
        Get.snackbar('Berhasil', data['message'],
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
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
}
