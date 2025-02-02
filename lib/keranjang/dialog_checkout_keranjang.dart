import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

class DialogCheckoutKeranjang extends StatelessWidget {
  DialogCheckoutKeranjang(
      {super.key,
      // required this.valueBox,
      // required this.jumlahControllers,
      // required this.initValueBo
      x});
  // final RxList<bool> valueBox;
  final KeranjangController _keranjangController = Get.find();
  // final List<TextEditingController> jumlahControllers;
  // final VoidCallback initValueBox;
  final LaporanController _laporanController = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Konfirmasi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text("Anda yakin menjual produk ini?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () {
              confirmJual();
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

      // _keranjangController.refreshProduk();

      await _keranjangController.initValueBox();
      Get.back();

      Get.snackbar("Terjual", "Penjualan Selesai",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.blue);
    } else {
      Get.back();
      Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }
}
