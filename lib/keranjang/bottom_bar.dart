import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/dialog_checkout_keranjang.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});
  static final ProductController _productController = Get.find();

  static final KeranjangController _keranjangController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _keranjangController.keranjangProduk.isEmpty
          ? const SizedBox.shrink()
          : Container(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Spacer(),
                    totalHargaJual(),
                    const Spacer(),
                    IconButton(
                        iconSize: 50,
                        onPressed: () async {
                          if (!HalamanKeranjang.haveValueBox()) {
                            if (!_keranjangController.hasSnackbar.value) {
                              _keranjangController.hasSnackbar.value = true;
                              Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
                                  snackPosition: SnackPosition.BOTTOM,
                                  colorText: Colors.white,
                                  backgroundColor: Colors.red);
                              await Future.delayed(const Duration(seconds: 3));
                              _keranjangController.hasSnackbar.value = false;
                            }
                          } else {
                            Get.dialog(DialogCheckoutKeranjang());
                          }
                        },
                        icon: const Icon(
                          Icons.shopping_cart_checkout,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            );
    });
  }

  Text totalHargaJual() {
    int totalHarga = 0;
    for (int i = 0; i < _keranjangController.valueBox.length; i++) {
      if (_keranjangController.valueBox[i] == true) {
        final harga = int.tryParse(_keranjangController.hargaJual[i]) ?? 0;
        final jumlah =
            int.tryParse(_keranjangController.jumlahControllers[i].text) ?? 1;
        final hargaJumlah = harga * jumlah;
        totalHarga = totalHarga + hargaJumlah;
      }
    }

    final convertHarga = _productController.regexNominal(totalHarga.toString());

    return Text(
      totalHarga == 0 ? '' : "Rp $convertHarga",
      style: const TextStyle(color: Colors.white, fontSize: 24),
    );
  }
}
