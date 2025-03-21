import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/dialog_checkout_keranjang.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

class BottomBar extends StatelessWidget with DialogPenjualan {
  BottomBar({super.key});
  static final ProductController _productController = Get.find();

  static final KeranjangController _keranjangController = Get.find();
  final potonganDiskon = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _keranjangController.keranjangProduk.isEmpty
          ? const SizedBox.shrink()
          : Container(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      const Spacer(),
                      Column(
                        children: [totalHargaJual(), textPotonganDiskon()],
                      ),
                      const Spacer(),
                      IconButton(
                          iconSize: 50,
                          onPressed: () async {
                            if (!HalamanKeranjang.haveValueBox()) {
                              if (!_keranjangController.hasSnackbar.value) {
                                _keranjangController.hasSnackbar.value = true;
                                Get.snackbar(
                                    "Gagal", "Pilih setidaknya 1 produk",
                                    snackPosition: SnackPosition.BOTTOM,
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red);
                                await Future.delayed(
                                    const Duration(seconds: 3));
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
              ),
            );
    });
  }

  Text totalHargaJual() {
    int totalHarga = 0;
    int totalDiskon = 0;
    if (_keranjangController.valueBox.length !=
        _keranjangController.jumlahControllers.length) {
      return Text('');
    }
    for (int i = 0; i < _keranjangController.valueBox.length; i++) {
      if (_keranjangController.valueBox[i] == true) {
        final hargaController = _keranjangController.hargaJual[i] ?? 0;
        final harga = int.tryParse(hargaController) ?? 0;
        final jumlah =
            int.tryParse(_keranjangController.jumlahControllers[i].text) ?? 1;
        // print('harga $harga');
        final hargaJumlah = harga * jumlah;
        totalHarga += hargaJumlah;
        final produkKeranjang = _keranjangController.keranjangProduk[i];
        final diskon = produkKeranjang['diskon'] ?? 0;
        final minProduk = produkKeranjang['min_produk'] ?? 0;
        // hitungSatuanItem(minProduk, diskon, hargaJumlah, jumlah);
        if (diskon > 0 && minProduk > 0) {
          final jumlahProdukDiskon = jumlah / minProduk;
          int hitungDiskon = (diskon * jumlahProdukDiskon.floor()).toInt();
          // print(hitungDiskon);
          totalDiskon += hitungDiskon;
          int totalHargaDiskon = hargaJumlah - hitungDiskon;
          // print(totalHargaiskon);
          _keranjangController.hargaJualItem.add(totalHargaDiskon);
        } else {
          _keranjangController.hargaJualItem.add(hargaJumlah);
        }
        // print(hitungDiskon);

        // print(_keranjangController.hargaJualItem);
        // totalHarga = totalHargaNormal - totalDiskon;
      } else {
        _keranjangController.hargaJualItem.add(0);
      }
    }

    // print(totalDiskon);
    final hargaFinal = totalHarga - totalDiskon;

    potonganDiskon.value = totalDiskon;
    final convertHarga = _productController.regexNominal(hargaFinal.toString());

    return Text(
      totalHarga == 0 ? '' : "Rp $convertHarga",
      style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
    );
  }

  Text textPotonganDiskon() {
    final diskon =
        _productController.regexNominal(potonganDiskon.value.toString());
    return Text(
      'Hemat Rp $diskon',
      style: TextStyle(color: Colors.white),
    );
  }
}
