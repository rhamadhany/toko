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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.blue)),
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

              final listKey = <String>[];

              // _keranjangController.valueBox
              //     .where((v) => v == true)
              //     .toList();
              // print(listKey);
              for (int i = 0; i < _keranjangController.valueBox.length; i++) {
                if (_keranjangController.valueBox[i] == true) {
                  final key =
                      _keranjangController.keranjangProduk[i]['kode_produk'];
                  // _keranjangController.removeProduk(key);
                  listKey.add(key);
                  // _keranjangController.loadProduk();
                }
              }
              await _keranjangController.removeProduk(listKey);

              await _keranjangController.initValueBox();
              // _keranjangController.refreshProduk();
            },
            child: const Text("Ya"))
      ],
    );
  }
}
