import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/lihat/gambar_penuh.dart';
import 'package:myapp/keranjang/app_bar_row.dart';
import 'package:myapp/keranjang/bottom_bar.dart';
import 'package:myapp/keranjang/check_box_all.dart';
import 'package:myapp/keranjang/jumlah_keranjang.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/lihat/logo_produk.dart';

class HalamanKeranjang extends StatelessWidget {
  const HalamanKeranjang({super.key, required this.isManager});
  static final KeranjangController _keranjangController = Get.find();
  static final ProductController _productController = Get.find();
  final bool isManager;
  @override
  Widget build(BuildContext context) {
    _keranjangController.initValueBox();
    // initValueBox();
    return Obx(() {
      return PopScope(
        onPopInvokedWithResult: (_, __) {
          _keranjangController.valueBox.value = List.generate(
              _keranjangController.valueBox.length, (index) => false);

          // _keranjangController.jumlahControllers.clear();
          // _keranjangController.hargaJual.clear();
        },
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                title: AppBarRow(
                  isManager: isManager,
                )),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _keranjangController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    )
                  : _keranjangController.keranjangProduk.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.shopping_cart,
                            size: Get.height * 0.3,
                          ),
                        )
                      : Column(
                          children: [
                            const CheckBoxAll(),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: _keranjangController
                                      .keranjangProduk.length,
                                  itemBuilder: (context, indexKeranjang) {
                                    final produkKeranjang = _keranjangController
                                        .keranjangProduk[indexKeranjang];

                                    // print('produkKeranjang $produkKeranjang');
                                    final gambarThumb =
                                        gambarIndex(produkKeranjang);
                                    return InkWell(
                                      onTap: () {
                                        _keranjangController
                                                .valueBox[indexKeranjang] =
                                            !_keranjangController
                                                .valueBox[indexKeranjang];
                                      },
                                      child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            children: [
                                              Obx(() {
                                                return Checkbox(
                                                    activeColor: Colors.blue,
                                                    value: _keranjangController
                                                            .valueBox[
                                                        indexKeranjang],
                                                    onChanged: (value) {
                                                      _keranjangController
                                                                  .valueBox[
                                                              indexKeranjang] =
                                                          value ?? false;
                                                    });
                                              }),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: gambarThumb != ""
                                                      ? InkWell(
                                                          onTap: () {
                                                            final indexGambar = _productController
                                                                .allProduct
                                                                .indexWhere((all) =>
                                                                    all['kode_produk'] ==
                                                                    produkKeranjang[
                                                                        'kode_produk']);
                                                            if (indexGambar !=
                                                                -1) {
                                                              Get.dialog(
                                                                  AlertDialog(
                                                                title: Text(
                                                                  produkKeranjang[
                                                                      'produk'],
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                content:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Row(
                                                                    children: (_productController.allProduct[indexGambar]['gambar']
                                                                            as List<
                                                                                dynamic>)
                                                                        .map((gambar) =>
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Get.to(() => GambarPenuh(gambar: gambar));
                                                                              },
                                                                              child: logoProduk(gambar, 10, Get.height * 0.5, 1),
                                                                            ))
                                                                        .toList(),
                                                                  ),
                                                                ),
                                                              ));
                                                            }
                                                          },
                                                          child: logoProduk(
                                                              gambarThumb,
                                                              10,
                                                              Get.height * 0.1,
                                                              2.5),
                                                        )
                                                      : noLogoProduk(
                                                          Get.height * 0.1, 10),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: Get.width * 0.5,
                                                      child: Text(
                                                        produkKeranjang[
                                                            'produk'],
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              'Sisa: ${sisa(produkKeranjang['kode_produk'])}',
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                            hargaBarang(
                                                                produkKeranjang[
                                                                    'kode_produk']),
                                                          ],
                                                        ),
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
                                          )),
                                    );
                                  }),
                            ),
                          ],
                        ),
            ),
            bottomNavigationBar: const BottomBar()),
      );
    });
  }

  Text hargaBarang(String keyKeranjang) {
    final indexKeys = _productController.allProduct
        .indexWhere((product) => product['kode_produk'] == keyKeranjang);
    final harga = indexKeys != -1
        ? _productController.allProduct[indexKeys]['harga_jual']
        : 0;
    final hargaFinal = _productController.regexNominal(harga.toString());
    return Text(
      "Rp $hargaFinal",
      style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 12),
    );
  }

  String? gambarIndex(Map<String, dynamic> produk) {
    final indexKey = _productController.allProduct
        .indexWhere((semua) => semua['kode_produk'] == produk['kode_produk']);

    if (indexKey != -1) {
      final gambar = _productController.allProduct[indexKey]['gambar'];
      if (gambar is List && gambar.isNotEmpty) {
        return gambar[0];
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String sisa(String keyKeranjang) {
    final indexKeys = _productController.allProduct
        .indexWhere((product) => product['kode_produk'] == keyKeranjang);
    if (indexKeys != -1) {
      final sisa = _productController.allProduct[indexKeys]['stok'] -
          _productController.allProduct[indexKeys]['terjual'];
      return sisa.toString();
    }
    return '0';
  }

  static bool haveValueBox() {
    return _keranjangController.valueBox.any((any) => any == true);
  }
}
