import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/QRCode/qr_view.dart';

import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/dialog_jual.dart';
import 'package:myapp/gambar_penuh.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

import 'package:myapp/logo_produk.dart';

import 'package:myapp/produk%20baru/produk_baru.dart';
import 'package:myapp/controller/product_controller.dart';

class LihatProduk extends StatelessWidget {
  LihatProduk({super.key, required this.produk});
  final RxMap<String, dynamic> produk;
  final ProductController _productController = Get.find();

  final KeranjangController _keranjangController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  @override
  Widget build(BuildContext context) {
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
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Get.to(() => QRView(
                            produk: produk,
                          ));
                    },
                    icon: const Icon(Icons.qr_code, color: Colors.white)),
                IconButton(
                    onPressed: () {
                      Get.to(() => const HalamanKeranjang());
                    },
                    icon: const Icon(Icons.shopping_cart_checkout,
                        color: Colors.white))
              ],
            )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (produk['gambar'].toString() == '[]') noLogoProduk(300, 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: Get.width * 0.09,
                      ),
                      ...(produk['gambar'] as List<dynamic>).map((picPath) {
                        return InkWell(
                            onTap: () {
                              Get.to(() => GambarPenuh(
                                    gambar: picPath,
                                  ));
                            },
                            child: logoProduk(picPath, 10, 300, 2.5));
                      })
                    ],
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            hargaProduk(),
                            produkTerjual(),
                            if (sisa > 0) sisaProduk(sisa),
                            if (_biometrikController.tabIndex.value == 1 ||
                                _biometrikController.tabIndex.value == 2)
                              profitJual(),
                            if (_biometrikController.tabIndex.value == 1 ||
                                _biometrikController.tabIndex.value == 2)
                              biayaBeli(),
                            if (_biometrikController.tabIndex.value == 1 ||
                                _biometrikController.tabIndex.value == 2)
                              omsetJual(),
                          ],
                        ),
                        const Spacer(),
                        kategoriView(),
                      ],
                    ),
                  ),
                ),
                deskripsiView(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            if (_biometrikController.tabIndex.value == 1 ||
                _biometrikController.tabIndex.value == 2)
              const BottomNavigationBarItem(
                  icon: Icon(Icons.edit_note), label: 'Edit'),
            if (_biometrikController.tabIndex.value == 0)
              const BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_checkout), label: 'Jual'),
          ],
          currentIndex: _productController.bottomIndex.value,
          onTap: (value) {
            _productController.bottomIndex.value = value;
            if (value == 0 && _biometrikController.tabIndex.value == 1) {
              editProduk();
            } else if (value == 0 && _biometrikController.tabIndex.value == 0) {
              _keranjangController.langsungtambahkeKeranjang(sisa, produk);
            } else {
              final sisa = produk['stok'] - produk['terjual'];
              if (sisa > 0) {
                _productController.jualController.value.text = '0';
                Get.dialog(DialogJual(
                  produk: produk,
                ));
              } else {
                Get.snackbar("Stok", "${produk['produk']} kosong",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white);
              }
            }
          },
        ),
      );
    });
  }

  void editProduk() {
    for (var controller in _productController.listTextField) {
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

      final gambar = (produk['gambar'] as List<dynamic>)
          .cast<String>()
          .map((e) => e.trim())
          .toList()
          .obs;

      Get.to(() => NewProduct(listPictures: gambar, produkEdit: produk));
    }
  }

  Text sisaProduk(int sisa) {
    return Text(
      sisa > 0 ? "Sisa: $sisa" : "",
      style: const TextStyle(fontSize: 18),
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

  Row omsetJual() {
    final omsetNormal = nilaiOmset().toString();
    final omsetFinal = _productController.regexNominal(omsetNormal);
    return Row(
      children: [
        const Text(
          "Omset: ",
          style: TextStyle(fontSize: 18),
        ),
        Text(
          "Rp $omsetFinal",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Row biayaBeli() {
    final nilaiNormal = nilaiBeli().toString();
    final nilaiFinal = _productController.regexNominal(nilaiNormal);
    return Row(
      children: [
        const Text(
          "Modal: ",
          style: TextStyle(fontSize: 18),
        ),
        Text(
          "Rp $nilaiFinal",
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
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

  Row profitJual() {
    final profitNormal = nilaiProfit().toString();
    final profitFinal = _productController.regexNominal(profitNormal);
    return Row(
      children: [
        const Text("Laba : ", style: TextStyle(fontSize: 18)),
        Text('Rp $profitFinal', style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Padding hargaProduk() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "Rp ${_productController.hargaProduk(produk)}",
        style: const TextStyle(
            fontSize: 35,
            color: Colors.deepOrangeAccent,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Text produkTerjual() {
    return Text(
      'Terjual: ${produk['terjual']}/${produk['stok']}',
      style: const TextStyle(
        fontSize: 18,
      ),
    );
  }

  kategoriView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            produk['kategori'],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }

  deskripsiView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Deskripsi',
              softWrap: true,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              produk['deskripsi'],
              softWrap: true,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
