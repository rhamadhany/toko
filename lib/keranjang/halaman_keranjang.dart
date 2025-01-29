// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/gambar_penuh.dart';
import 'package:myapp/keranjang/jumlah_keranjang.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/logo_produk.dart';

class HalamanKeranjang extends StatelessWidget {
  HalamanKeranjang({super.key});
  final KeranjangController _keranjangController = Get.find();
  final ProductController _productController = Get.find();
  final List<TextEditingController> jumlahControllers = [];
  final RxList<bool> valueBox = RxList<bool>();
  final boxAll = false.obs;
  final hargaJual = [];
  // final _loadingKeranjang = true.obs;
  void _initValueBox() {
    // _loadingKeranjang.value = true;
    hargaJual.clear();
    valueBox.clear();
    jumlahControllers.clear();
    _keranjangController.loadProduk();
    for (int i = 0; i < _keranjangController.keranjangProduk.length; i++) {
      valueBox.add(false);
      final harga = _productController.allProduct.firstWhere((product) =>
          product['key'] ==
          _keranjangController.keranjangProduk[i]['key'])['harga_jual'];

      hargaJual.add(harga);

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
          child: _keranjangController.keranjangProduk.isEmpty
              ? const Center(
                  child: Text(
                    "Keranjang kosong",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    Card(
                      child: Row(
                        children: [
                          Checkbox(
                              value: boxAll.value,
                              onChanged: (value) {
                                boxAll.value = value ?? false;
                                if (value == true) {
                                  for (int i = 0; i < valueBox.length; i++) {
                                    valueBox[i] = true;
                                  }
                                } else {
                                  for (int i = 0; i < valueBox.length; i++) {
                                    valueBox[i] = false;
                                  }
                                }
                              }),
                          const Spacer(),
                          const Text(
                            "Pilih Semua",
                            style: TextStyle(fontSize: 18),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount:
                              _keranjangController.keranjangProduk.length,
                          itemBuilder: (context, indexKeranjang) {
                            // if (indexKeranjang == 0) {
                            //   CheckboxListTile(
                            //       title: Text("Pilih Semua"),
                            //       value: boxAll.value,
                            //       onChanged: (value) {
                            //         boxAll.value = value ?? false;
                            //       });
                            // }

                            final produkKeranjang = _keranjangController
                                .keranjangProduk[indexKeranjang];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0, vertical: 2),
                              child: Card(
                                  child: Row(
                                children: [
                                  Obx(() {
                                    return Checkbox(
                                        value: valueBox[indexKeranjang],
                                        onChanged: (value) {
                                          valueBox[indexKeranjang] =
                                              value ?? false;
                                        });
                                  }),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: produkKeranjang['gambar'] != ""
                                          ? InkWell(
                                              onTap: () {
                                                final indexGambar =
                                                    _productController
                                                        .allProduct
                                                        .indexWhere((all) =>
                                                            all['key'] ==
                                                            produkKeranjang[
                                                                'key']);
                                                if (indexGambar != -1) {
                                                  Get.dialog(AlertDialog(
                                                    content:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        children: (_productController
                                                                            .allProduct[
                                                                        indexGambar]
                                                                    ['gambar']
                                                                as List<
                                                                    dynamic>)
                                                            .map(
                                                                (gambar) =>
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Get.to(() =>
                                                                            GambarPenuh(gambar: gambar));
                                                                      },
                                                                      child: logoProduk(
                                                                          gambar,
                                                                          10,
                                                                          Get.height *
                                                                              0.5,
                                                                          1),
                                                                    ))
                                                            .toList(),
                                                      ),
                                                    ),
                                                  ));
                                                }
                                              },
                                              child: logoProduk(
                                                  produkKeranjang['gambar'],
                                                  10,
                                                  Get.height * 0.1,
                                                  2.5),
                                            )
                                          : const Icon(Icons.image),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produkKeranjang['produk'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            hargaBarang(produkKeranjang['key']),
                                            JumlahKeranjang(
                                              jumlahControllers:
                                                  jumlahControllers,
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
                  ],
                ),
        ),
        bottomNavigationBar: _keranjangController.keranjangProduk.isEmpty
            ? null
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
                          onPressed: () {
                            if (!valueBox.toString().contains('true')) {
                              Get.snackbar("Gagal", "Pilih setidaknya 1 produk",
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            Get.dialog(AlertDialog(
                              title: const Text('Konfirmasi'),
                              content:
                                  const Text("Anda yakin menjual produk ini?"),
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
    return Text(
      "Rp $hargaFinal",
      style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 12),
    );
  }

  Future<void> confirmJual() async {
    if (valueBox.toString().contains('true')) {
      for (int i = 0; i < valueBox.length; i++) {
        // print("valueBox: ${valueBox[i]}");
        if (valueBox[i] == true) {
          // final harga = int.tryParse(hargaJual[i]) ?? 0;
          final key = _keranjangController.keranjangProduk[i]['key'];
          final jumlah = int.tryParse(jumlahControllers[i].text) ?? 1;
          await DBHelper.updateTerjual(key, jumlah);
          await _keranjangController.removeProduk(key);
          // valueBox.removeAt(i);
          // hargaJual.removeAt(i);
          // jumlahControllers.removeAt(i);
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
