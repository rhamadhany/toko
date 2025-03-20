import 'package:flutter/foundation.dart';
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
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .blue)),
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
                                                                  .map((gambar) =>
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Get.to(() =>
                                                                                GambarPenuh(gambar: gambar));
                                                                          },
                                                                          child:
                                                                              FutureLogoOnline(
                                                                            gambar:
                                                                                gambar['base64'],
                                                                            size:
                                                                                Get.height * 0.25,
                                                                            childOnly:
                                                                                true,
                                                                          )))
                                                                  .toList(),
                                                            ),
                                                          ),
                                                        ));
                                                      }
                                                    },
                                                    child: FutureLogoOnline(
                                                      gambar: gambarThumb!,
                                                      size: kIsWeb
                                                          ? Get.height * 0.2
                                                          : Get.height * 0.1,
                                                      childOnly: true,
                                                    ))
                                                : noLogoProduk(
                                                        kIsWeb
                                                            ? Get.height * 0.2
                                                            : Get.height * 0.1,
                                                        10)
                                                    .child,
                                          ),
                                        ),
                                        if (kIsWeb) Spacer(),
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
                                                      fontSize:
                                                          kIsWeb ? 30 : 16,
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
                                                            fontSize: kIsWeb
                                                                ? 18
                                                                : 12),
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
