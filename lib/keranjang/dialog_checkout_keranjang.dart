import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class DialogCheckoutKeranjang extends StatelessWidget {
  DialogCheckoutKeranjang({
    super.key,
  });

  final KeranjangController _keranjangController = Get.find();
  final BiometrikController _biometrikController = Get.find();

  final LaporanController _laporanController = Get.find();
  @override
  Widget build(BuildContext context) {
    _biometrikController.hasAuthenticated.value = false;

    return AlertDialog(
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
                final hasAuth = await _biometrikController.authReuired();
                if (hasAuth) {
                  _biometrikController.hasAuthenticated.value = true;
                }

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

  Future<void> confirmJual() async {
    if (HalamanKeranjang.haveValueBox()) {
      for (int i = 0; i < _keranjangController.valueBox.length; i++) {
        if (_keranjangController.valueBox[i] == true) {
          final key = _keranjangController.keranjangProduk[i]['key'];
          final jumlah =
              int.tryParse(_keranjangController.jumlahControllers[i].text) ?? 1;
          await DBHelper.updateTerjual(key, jumlah);
          _laporanController.tambahJual(key, jumlah, 'penjualan');
          await _keranjangController.removeProduk(key);
        }
      }

      await _keranjangController.initValueBox();

      Get.snackbar("Terjual", "Penjualan Selesai",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.blue);
    } else {
      Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }
}
