import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/keranjang/jumlah_keranjang.dart';
import 'package:myapp/keranjang_controller.dart';
import 'package:myapp/product_controller.dart';

class HalamanKeranjang extends StatelessWidget {
  HalamanKeranjang({super.key});
  final KeranjangController _keranjangController = Get.find();
  final ProductController _productController = Get.find();
  final List<TextEditingController> jumlahControllers = [];
  final RxList<bool> valueBox = RxList<bool>();
  final hargaJual = [];
  // final _loadingKeranjang = true.obs;
  void _initValueBox() {
    // _loadingKeranjang.value = true;
    valueBox.clear();
    for (int i = 0; i < _keranjangController.keranjangProduk.length; i++) {
      valueBox.add(false);
      final jumlahController = TextEditingController();
      jumlahController.text =
          _keranjangController.keranjangProduk[i]['jumlah'].toString();
      jumlahControllers.add(jumlahController);
    }
    // _loadingKeranjang.value = false;
  }

  @override
  Widget build(BuildContext context) {
    _initValueBox();
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Keranjang",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: _keranjangController.keranjangProduk.length,
              itemBuilder: (context, indexKeranjang) {
                final produkKeranjang =
                    _keranjangController.keranjangProduk[indexKeranjang];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
                  child: Card(
                      child: Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                            value: valueBox[indexKeranjang],
                            onChanged: (value) {
                              valueBox[indexKeranjang] = value ?? false;
                            });
                      }),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: produkKeranjang['gambar'] != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        File(produkKeranjang['gambar']),
                                        width: 80,
                                        height: 80,
                                      ),
                                    )
                                  : const Icon(Icons.image),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produkKeranjang['produk'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                hargaBarang(produkKeranjang['key']),
                                JumlahKeranjang(
                                  jumlahControllers: jumlahControllers,
                                  indexKeranjang: indexKeranjang,
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
                );
              }),
        ),
        bottomNavigationBar: Container(
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
                    onPressed: () {
                      if (!valueBox.toString().contains('true')) {
                        Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      Get.dialog(AlertDialog(
                        title: const Text('Konfirmasi'),
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
                      ));
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
    for (int i = 0; i < valueBox.length; i++) {
      if (valueBox[i] == true) {
        final harga = int.tryParse(hargaJual[i]) ?? 0;
        final jumlah = int.tryParse(jumlahControllers[i].text) ?? 1;
        final hargaJumlah = harga * jumlah;
        totalHarga = totalHarga + hargaJumlah;
      }
    }

    final convertHarga = _productController.regexNominal(totalHarga.toString());

    return Text(
      "Rp $convertHarga",
      style: const TextStyle(color: Colors.white, fontSize: 24),
    );
  }

  Text hargaBarang(String keyKeranjang) {
    final indexKeys = _productController.allProduct
        .indexWhere((product) => product['key'] == keyKeranjang);
    final harga = indexKeys != -1
        ? _productController.allProduct[indexKeys]['harga_jual']
        : 0;
    final hargaFinal = _productController.regexNominal(harga);
    hargaJual.add(harga);
    return Text(
      "Rp $hargaFinal",
      style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 12),
    );
  }

  Future<void> confirmJual() async {
    if (valueBox.toString().contains('true')) {
      for (int i = 0; i < valueBox.length; i++) {
        if (valueBox[i] == true) {
          // final harga = int.tryParse(hargaJual[i]) ?? 0;
          final key = _keranjangController.keranjangProduk[i]['key'];
          final jumlah = int.tryParse(jumlahControllers[i].text) ?? 1;
          await DBHelper.updateTerjual(key, jumlah);
          await _keranjangController.removeProduk(key);
        }
      }
      _initValueBox();
      Get.back();

      Get.snackbar("Terjual", "Penjualan Selesai",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.back();
      Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
