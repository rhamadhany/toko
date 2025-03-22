import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/keranjang/dialog_penjualan.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class DialogCheckoutKeranjang extends StatelessWidget with DialogPenjualan {
  DialogCheckoutKeranjang({
    super.key,
  });
  final BiometrikController _biometrikController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.blue)),
      title: const Text(
        'Konfirmasi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text("Anda yakin menjual produk ini?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back(closeOverlays: false);
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () async {
              if (Settings.autentikasiAktif.value) {
                _biometrikController.hasAuthenticated.value =
                    await _biometrikController.authReuired();

                if (_biometrikController.hasAuthenticated.value) {
                  Get.back(closeOverlays: false);

                  confirmJual();
                } else {
                  Get.snackbar('Gagal', 'Autentikasi gagal',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red);
                }
              } else {
                Get.back(closeOverlays: false);

                confirmJual();
              }
            },
            child: const Text("Ya")),
      ],
    );
  }
}
