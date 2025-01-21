import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/product_controller.dart';

class DialogJual extends StatelessWidget {
  DialogJual({super.key, required this.produk});
  final ProductController _productController = Get.find();
  final RxMap<String, dynamic> produk;
  final RxBool showSnackbarStok = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AlertDialog(
        title: const Text("Jual Produk"),
        content: Row(
          children: [
            IconButton(
                onPressed: () async {
                  await countJual(false);
                },
                icon: const Icon(Icons.remove)),
            Expanded(
              child: TextField(
                textAlign: TextAlign.center,
                controller: _productController.jualController.value,
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
                onPressed: () async {
                  await countJual(true);
                },
                icon: const Icon(Icons.add)),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () async {
                final count = _productController.jualController.value.text;
                int countInt = int.parse(count);

                final sisa = produk['stok'] - (produk['terjual'] + countInt);
                // print(sisa);

                if (sisa > -1) {
                  final terjualSebelumnya = produk['terjual'];

                  final terjualBaru =
                      int.parse(_productController.jualController.value.text);

                  produk['terjual'] = terjualSebelumnya + terjualBaru;
                  Get.back();
                  await _productController.updateProduct(produk);
                } else {
                  await stokTidakCukup(true);
                  // _productController.jualController.value.clear();
                  // print(sisa);
                }
              },
              child: const Text("Jual"))
        ],
      );
    });
  }

  Future countJual(bool add) async {
    final count = _productController.jualController.value.text;
    int countInt = int.parse(count);

    if (count.isEmpty) {
      Get.snackbar('Error', 'Masukkan jumlah jual');
      return;
    }
    try {
      final sisa = produk['stok'] - (produk['terjual'] + countInt);
      if (add) {
        if (sisa > 0) {
          countInt++;
        } else {
          await stokTidakCukup(false);
        }
      } else {
        if (countInt > 0) {
          countInt--;
        }
      }
      _productController.jualController.value.text = countInt.toString();
    } catch (e) {
      // print(e);
      _productController.jualController.value.text = "0";
    }
  }

  Future<void> stokTidakCukup(bool isJual) async {
    if (!showSnackbarStok.value) {
      Get.snackbar("Stok",
          "${produk['produk']} hanya tersisa ${produk['stok'] - produk['terjual']} produk",
          snackPosition: SnackPosition.BOTTOM);
      showSnackbarStok.value = true;
      if (isJual) {
        _productController.jualController.value.text =
            (produk['stok'] - produk['terjual']).toString();
      }

      await Future.delayed(const Duration(seconds: 3));
      showSnackbarStok.value = false;
    }
  }
}
