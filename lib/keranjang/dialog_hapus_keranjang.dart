import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
// import 'package:myapp/keranjang/halaman_keranjang.dart';

class DialogHapusKeranjang extends StatelessWidget {
  DialogHapusKeranjang({super.key});
  final KeranjangController _keranjangController = Get.find();
  // final VoidCallback initValueBox;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Hapus Produk",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content:
          const Text("Apakah anda ingin menghapus produk ini dari keranjang?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () async {
              Get.back();

              for (int i = 0; i < _keranjangController.valueBox.length; i++) {
                if (_keranjangController.valueBox[i] == true) {
                  final key = _keranjangController.keranjangProduk[i]['key'];
                  _keranjangController.removeProduk(key);
                  // _keranjangController.loadProduk();
                }
              }

              await _keranjangController.initValueBox();
              // _keranjangController.refreshProduk();
            },
            child: const Text("Ya"))
      ],
    );
  }
}
