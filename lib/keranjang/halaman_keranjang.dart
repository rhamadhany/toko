import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/keranjang/jumlah_keranjang.dart';
import 'package:myapp/keranjang_controller.dart';
import 'package:myapp/product_controller.dart';

class HalamanKeranjang extends StatelessWidget {
  HalamanKeranjang({super.key});
  final KeranjangController _keranjangController = Get.find();
  final ProductController _productController = Get.find();
  final List<TextEditingController> jumlahControllers = [];
  @override
  Widget build(BuildContext context) {
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
                final jumlahController = TextEditingController();
                jumlahController.text = produkKeranjang['jumlah'].toString();
                jumlahControllers.add(jumlahController);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Card(
                      child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: produkKeranjang['gambar'] != ""
                                ? Image.file(
                                    File(produkKeranjang['gambar']),
                                    width: 100,
                                    height: 100,
                                  )
                                : const Icon(Icons.image),
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
                                // textFieldJumlah(indexKeranjang),
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
      );
    });
  }

  Text hargaBarang(String keyKeranjang) {
    final product = _productController.allProduct
        .firstWhereOrNull((product) => product['key'] == keyKeranjang);
    final harga = product != null ? product['harga_jual'] : 0;
    final hargaFinal = _productController.regexNominal(harga);
    return Text(
      "Rp $hargaFinal",
      style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 10),
    );
  }
}
