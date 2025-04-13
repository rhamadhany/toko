import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/lihat/future_logo_online.dart';
import 'package:myapp/lihat/gambar_penuh.dart';
import 'package:myapp/lihat/harga_produk.dart';
import 'package:myapp/lihat/logo_produk.dart';
import 'package:myapp/lihat/view_deskripsi.dart';
import 'package:myapp/lihat/view_kategori_produk.dart';

class BodyLihatProduk extends GetView<ProductController> {
  const BodyLihatProduk(
      {super.key,
      required this.produk,
      required this.isManager,
      required this.sisa});
  final RxMap<String, dynamic> produk;
  final int sisa;
  final bool isManager;
  @override
  Widget build(BuildContext context) {
    // print(produk);

    return SizedBox(
      height: Get.height,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (produk['gambar'].toString() == '[]')
                    noLogoProduk(300, 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (produk['gambar'] is List)
                          ...produk['gambar'].map((picPath) {
                            return InkWell(
                              onTap: () {
                                Get.to(() =>
                                    GambarPenuh(gambar: picPath['base64']));
                              },
                              child: picPath is String
                                  ? FutureLogoOnline(
                                      size: 300,
                                      gambar: picPath,
                                      childOnly: false,
                                    )
                                  : cardGambar64(10, 2.5,
                                      base64Decode(picPath['base64']), 300),
                            );
                          }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue.withAlpha(50),
                              spreadRadius: 5,
                              blurRadius: 10)
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  produkTerjual(),
                                  if (sisa > 0) sisaProduk(sisa),
                                  if (isManager) profitJual(),
                                  if (isManager) biayaBeli(),
                                  if (isManager) omsetJual(),
                                ],
                              ),
                            ),
                            if (produk['kategori'] != null &&
                                produk['kategori'] != '')
                              ViewKategoriProduk(produk: produk),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (produk['deskripsi'] != null && produk['deskripsi'] != '')
                    ViewDeskripsi(
                      produk: produk,
                    )
                ],
              ),
            ),
          ),
          HargaProduk(
            produk: produk,
          )
        ],
      ),
    );
  }

  Text sisaProduk(int sisa) {
    return Text(
      sisa > 0 ? "SISA: $sisa" : "",
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }

  int nilaiOmset() {
    final terjual = produk['terjual'] ?? 0;
    final int hargaJual = int.tryParse(produk['harga_jual']) ?? 0;
    int omset = 0;

    if (terjual != 0) {
      omset = terjual * hargaJual;
    }
    return omset;
  }

  Text omsetJual() {
    final omsetNormal = nilaiOmset();
    final diskon = produk['diskon'];
    final hasil = omsetNormal - diskon;
    final omsetFinal = controller.regexNominal(hasil.toString());
    return Text("OMSET: Rp $omsetFinal",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ));
  }

  Text biayaBeli() {
    final nilaiNormal = nilaiBeli().toString();
    final nilaiFinal = controller.regexNominal(nilaiNormal);
    return Text("MODAL: Rp $nilaiFinal",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ));
  }

  int nilaiBeli() {
    final terjual = produk['terjual'] ?? 0;
    final int hargaBeli = int.tryParse(produk['harga_beli']) ?? 0;
    int biaya = 0;

    if (terjual != 0) {
      biaya = terjual * hargaBeli;
    }
    return biaya;
  }

  int nilaiProfit() {
    final terjual = produk['terjual'] ?? 0;
    final hargaBeli = int.tryParse(produk['harga_beli'] ?? '') ?? 0;

    final int nilaiBeli = terjual * hargaBeli;
    final int profit = nilaiOmset() - nilaiBeli;
    return profit;
  }

  Text profitJual() {
    final profitNormal = nilaiProfit().toString();
    final profitFinal = controller.regexNominal(profitNormal);
    return Text("LABA: Rp $profitFinal",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: Colors.white,
        ));
  }

  Text produkTerjual() {
    return Text(
      'TERJUAL: ${produk['terjual']}/${produk['stok']}',
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }
}
