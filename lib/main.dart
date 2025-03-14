import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/splash_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  Get.put(SplashController());

  runApp(
    GetMaterialApp(
      home: SplashLogin(),
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
    ),
  );
}
