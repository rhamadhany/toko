import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/check_box_all.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/keranjang/jumlah_keranjang.dart';
import 'package:myapp/lihat/future_logo_online.dart';
import 'package:myapp/lihat/gambar_penuh.dart';
import 'package:myapp/lihat/logo_produk.dart';

class BodyKeranjang extends GetView<KeranjangController> with KeranjangHelper {
  BodyKeranjang({super.key});
  static final _productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : controller.keranjangProduk.isEmpty
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
                            itemCount: controller.keranjangProduk.length,
                            itemBuilder: (context, indexKeranjang) {
                              final produkKeranjang =
                                  controller.keranjangProduk[indexKeranjang];

                              final gambarThumb = gambarIndex(produkKeranjang);
                              return InkWell(
                                onTap: () {
                                  controller.valueBox[indexKeranjang] =
                                      !controller.valueBox[indexKeranjang];
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
                                              value: controller
                                                  .valueBox[indexKeranjang],
                                              onChanged: (value) {
                                                controller.valueBox[
                                                        indexKeranjang] =
                                                    value ?? false;
                                              });
                                        }),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: gambarThumb != ""
                                                ? InkWell(
                                                    onTap: () {
                                                      final indexGambar = _productController
                                                          .allProduct
                                                          .indexWhere((all) =>
                                                              all['kode_produk'] ==
                                                              produkKeranjang[
                                                                  'kode_produk']);
                                                      if (indexGambar != -1) {
                                                        Get.dialog(AlertDialog(
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
                                                              children: (_productController
                                                                              .allProduct[indexGambar]
                                                                          [
                                                                          'gambar']
                                                                      as List<
                                                                          dynamic>)
                                                                  .map((gambar) => InkWell(
                                                                      onTap: () {
                                                                        Get.to(() =>
                                                                            GambarPenuh(gambar: gambar));
                                                                      },
                                                                      child:

                                                                          //  FutureBuilder(
                                                                          //     future: logoProdukOnline(gambar, 10, Get.height * 0.5, 1),
                                                                          //     builder: (context, snapshots) {
                                                                          //       if (snapshots.hasData && snapshots.data != null) {
                                                                          //         return snapshots.data!;
                                                                          //       } else {
                                                                          //         return Center(
                                                                          //           child: CircularProgressIndicator(
                                                                          //             color: Colors.blue,
                                                                          //           ),
                                                                          //         );
                                                                          //       }
                                                                          //     }),
                                                                          FutureLogoOnline(
                                                                        gambar:
                                                                            gambar,
                                                                        size: Get.height *
                                                                            0.5,
                                                                        childOnly:
                                                                            true,
                                                                      )))
                                                                  .toList(),
                                                            ),
                                                          ),
                                                        ));
                                                      }
                                                    },
                                                    child:

                                                        // FutureBuilder(
                                                        //     future: logoProdukOnline(
                                                        //         gambarThumb!,
                                                        //         10,
                                                        //         Get.height * 0.1,
                                                        //         2.5),
                                                        //     builder:
                                                        //         (context, snapshots) {
                                                        //       if (snapshots.hasData &&
                                                        //           snapshots.data !=
                                                        //               null) {
                                                        //         return snapshots
                                                        //             .data!;
                                                        //       } else {
                                                        //         return Center(
                                                        //           child:
                                                        //               CircularProgressIndicator(
                                                        //             color:
                                                        //                 Colors.blue,
                                                        //           ),
                                                        //         );
                                                        //       }
                                                        //     }),
                                                        FutureLogoOnline(
                                                      gambar: gambarThumb!,
                                                      size: Get.height * 0.1,
                                                      childOnly: true,
                                                    ))
                                                : noLogoProduk(
                                                        Get.height * 0.1, 10)
                                                    .child,
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
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: Get.width * 0.5,
                                                child: Text(
                                                  produkKeranjang['produk'],
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
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
      );
    });
  }
}
