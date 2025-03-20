import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/pengaturan/dialog_keluar_akun.dart';

class KeluarAkun extends StatelessWidget {
  const KeluarAkun({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
            iconColor: WidgetStatePropertyAll(Colors.black),
            iconSize: WidgetStatePropertyAll(35),
            backgroundColor: WidgetStatePropertyAll(Colors.white)),
        onPressed: () {
          Get.dialog(DialogKeluarAkun());
        },
        child: Icon(Icons.exit_to_app));
  }
}
