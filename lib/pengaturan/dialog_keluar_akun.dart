import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/splash_login.dart';

class DialogKeluarAkun extends StatelessWidget {
  DialogKeluarAkun({
    super.key,
  });

  final SplashController _splashController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue)),
      title: Text(
        'Konfirmasi',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      alignment: Alignment.center,
      content: Text('Keluar dari akun ${_splashController.username.value}?'),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Batal')),
        ElevatedButton(
            onPressed: () {
              Get.back();
              _splashController.box.remove('token');
              _splashController.box.remove('username');
              Get.offAll(SplashLogin());
            },
            child: Text('Keluar')),
      ],
    );
  }
}
