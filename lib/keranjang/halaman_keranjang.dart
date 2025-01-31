import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/gambar_penuh.dart';
import 'package:myapp/keranjang/app_bar_row.dart';
import 'package:myapp/keranjang/bottom_bar.dart';
import 'package:myapp/keranjang/check_box_all.dart';
import 'package:myapp/keranjang/jumlah_keranjang.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/logo_produk.dart';

class HalamanKeranjang extends StatelessWidget {
  const HalamanKeranjang({super.key});
  static final KeranjangController _keranjangController = Get.find();
  static final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    _keranjangController.initValueBox();
    // initValueBox();
    return Obx(() {
      return Scaffold(
          appBar: AppBar(title: const AppBarRow()),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _keranjangController.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : _keranjangController.keranjangProduk.isEmpty
                    ? const Center(
                        child: Text(
                          "Keranjang kosong",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Column(
                        children: [
                          const CheckBoxAll(),
                          Expanded(
                            child: ListView.builder(
                                itemCount:
                                    _keranjangController.keranjangProduk.length,
                                itemBuilder: (context, indexKeranjang) {
                                  final produkKeranjang = _keranjangController
                                      .keranjangProduk[indexKeranjang];

                                  return Card(
                                      child: Row(
                                    children: [
                                      Obx(() {
                                        return Checkbox(
                                            value: _keranjangController
                                                .valueBox[indexKeranjang],
                                            onChanged: (value) {
                                              _keranjangController.valueBox[
                                                      indexKeranjang] =
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
                                                                            .allProduct[indexGambar]
                                                                        [
                                                                        'gambar']
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
                                                                              Get.height * 0.5,
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
                                              : noLogoProduk(
                                                  Get.height * 0.1, 10),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              produkKeranjang['produk'],
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                hargaBarang(
                                                    produkKeranjang['key']),
                                                JumlahKeranjang(
                                                  // jumlahControllers:
                                                  //     jumlahControllers,
                                                  indexKeranjang:
                                                      indexKeranjang,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ));
                                }),
                          ),
                        ],
                      ),
          ),
          bottomNavigationBar: const BottomBar());
    });
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

  static bool haveValueBox() {
    return _keranjangController.valueBox.any((any) => any == true);
  }
}
