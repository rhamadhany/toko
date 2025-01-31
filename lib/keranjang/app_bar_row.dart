import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/keranjang/dialog_hapus_keranjang.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

class AppBarRow extends StatelessWidget {
  const AppBarRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          const Text(
            "Keranjang",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                Get.to(() => QRScanner(
                      dariKeranjang: true,
                    ));
              },
              icon: const Icon(Icons.qr_code_scanner)),
          if (HalamanKeranjang.haveValueBox())
            IconButton(
                onPressed: () {
                  Get.dialog(DialogHapusKeranjang(
                      // initValueBox: _keranjangController.initValueBox,
                      ));
                },
                icon: const Icon(Icons.delete_forever))
        ],
      );
    });
  }
}
