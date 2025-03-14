import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/QRCode/qr_view.dart';
import 'package:myapp/controller/main_controller.dart';

import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/lihat/dialog_jual.dart';
import 'package:myapp/lihat/gambar_penuh.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

import 'package:myapp/lihat/logo_produk.dart';

import 'package:myapp/produk%20baru/produk_baru.dart';
import 'package:myapp/controller/product_controller.dart';

class LihatProduk extends GetView<ProductController> {
  LihatProduk({super.key, required this.produk, required this.isManager});
  final bool isManager;
  final RxMap<String, dynamic> produk;

  final KeranjangController _keranjangController = Get.find();

  final MainController _mainController = Get.find();
  @override
  Widget build(BuildContext context) {
    if (controller.isNeedRefreshProduk.value) {
      produk['gambar'] = controller.refreshProdukUpdate(produk['kode_produk']);
      controller.isNeedRefreshProduk.value = false;
    }
    return Obx(() {
      final sisa = produk['stok'] - produk['terjual'];

      return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${produk['produk']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Get.to(() => QRView(produk: produk));
                },
                icon: const Icon(Icons.qr_code, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Get.to(() => HalamanKeranjang(
                        isManager: isManager,
                      ));
                },
                icon: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: SizedBox(
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
                            if (produk['gambar'] is List<dynamic>)
                              ...(produk['gambar'] as List<dynamic>)
                                  .map((picPath) {
                                return InkWell(
                                  onTap: () {
                                    Get.to(() => GambarPenuh(
                                        gambar: picPath is String
                                            ? picPath
                                            : picPath['base64']));
                                  },
                                  child: picPath is String
                                      ? FutureBuilder(
                                          future: logoProdukOnline(
                                              picPath, 10, 300, 2.5),
                                          builder: (context, snapshots) {
                                            if (snapshots.hasData &&
                                                snapshots.data != null) {
                                              return snapshots.data!;
                                            } else {
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  noLogoProduk(300, 10),
                                                  CircularProgressIndicator(
                                                    color: Colors.blue,
                                                  ),
                                                ],
                                              );
                                            }
                                          })
                                      : cardGambar64(10, 2.5,
                                          base64Decode(picPath['base64']), 300),
                                );
                              }),
                            if (produk['gambar'] is String)
                              InkWell(
                                onTap: () {
                                  if (produk['gambar'] != '') {
                                    Get.to(() =>
                                        GambarPenuh(gambar: produk['gambar']));
                                  }
                                },
                                child: FutureBuilder(
                                    future: logoProdukOnline(
                                        produk['gambar'], 10, 300, 2.5),
                                    builder: (context, snapshots) {
                                      if (snapshots.hasData &&
                                          snapshots.data != null) {
                                        return snapshots.data!;
                                      } else {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            noLogoProduk(300, 10),
                                            CircularProgressIndicator(
                                              color: Colors.blue,
                                            ),
                                          ],
                                        );
                                      }
                                    }),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  kategoriView(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (produk['deskripsi'] != null &&
                          produk['deskripsi'] != '')
                        deskripsiView(),
                    ],
                  ),
                ),
              ),
              hargaProduk(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: [
            if (isManager)
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.edit_note,
                ),
                label: 'Edit',
              ),
            if (!isManager)
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Keranjang',
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_checkout),
              label: 'Jual',
            ),
          ],
          currentIndex: controller.bottomIndex.value,
          onTap: (value) {
            controller.bottomIndex.value = value;
            if (value == 0 &&
                (_mainController.tabIndex.value == 1 ||
                    _mainController.tabIndex.value == 2)) {
              editProduk();
            } else if (value == 0 && _mainController.tabIndex.value == 0) {
              _keranjangController.langsungtambahkeKeranjang(sisa, produk);
            } else {
              final sisa = produk['stok'] - produk['terjual'];
              if (sisa > 0) {
                controller.jualController.value.text = '0';
                Get.dialog(DialogJual(produk: produk));
              } else {
                Get.snackbar(
                  "Stok",
                  "${produk['produk']} kosong",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            }
          },
        ),
      );
    });
  }

  void editProduk() {
    for (var controller in controller.listTextField) {
      switch (controller['label']) {
        case 'Nama Produk':
          controller['controller'].text = produk['produk'];
          break;
        case 'Harga Beli':
          controller['controller'].text = produk['harga_beli'];
          break;
        case 'Harga Jual':
          controller['controller'].text = produk['harga_jual'];
          break;
        case 'Terjual':
          controller['controller'].text = produk['terjual'].toString();
          break;
        case 'Stok':
          controller['controller'].text = produk['stok'].toString();
          break;
      }
    }

    // print(produk['gambar']);

    final gambar = produk['gambar'] is List<dynamic>
        ? (produk['gambar'] as List<dynamic>)
            .cast<String>()
            .map((e) => e.trim())
            .toList()
            .obs
        : produk['gambar'] == ''
            ? [].obs
            : [produk['gambar']].obs;

    controller.kategoriAdd.value = produk['kategori'];

    Get.to(() => NewProduct(listPictures: gambar, produkEdit: produk));
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
    final omsetNormal = nilaiOmset().toString();
    final omsetFinal = controller.regexNominal(omsetNormal);
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

  Widget hargaProduk() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
          child: Text(
            "Rp ${controller.hargaProduk(produk)}",
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
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

  Widget kategoriView() {
    final indexIcons = controller.daftarKategori
        .indexWhere((ind) => ind['kategori'] == produk['kategori']);
    return Container(
      decoration: BoxDecoration(
          color: Colors.purple, borderRadius: BorderRadius.circular(5)),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconData(controller.daftarKategori[indexIcons]['icon'],
                    fontFamily: 'MaterialIcons'),
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  produk['kategori'].length > 12
                      ? produk['kategori'].substring(0, 12) + '...'
                      : produk['kategori'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  deskripsiView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      textAlign: TextAlign.center,
                      'DESKRIPSI',
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 8),
              child: SelectableText(
                produk['deskripsi'],
                maxLines: null,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
