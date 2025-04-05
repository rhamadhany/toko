import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/QRCode/qr_view.dart';

import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/lihat/body_lihat_produk.dart';
import 'package:myapp/lihat/dialog_jual.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';
import 'package:myapp/lihat/grosir_helper.dart';

import 'package:myapp/produk%20baru/produk_baru.dart';
import 'package:myapp/controller/product_controller.dart';

class LihatProduk extends GetView<ProductController>
    with DialogJualHelper, GrosirHelper {
  LihatProduk({super.key, required this.isManager});
  final bool isManager;
  // final RxMap<String, dynamic> loadProduk;

  final KeranjangController _keranjangController = Get.find();
  static final RxMap<String, dynamic> produk = <String, dynamic>{}.obs;
  @override
  Widget build(BuildContext context) {
    // updateDiskon();
    loadListGrosir();

    return Obx(() {
      // produk.value = loadProduk;

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
        body: BodyLihatProduk(
          produk: produk,
          isManager: isManager,
          sisa: sisa,
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
            if (isManager && value == 0) {
              editProduk();
            } else if (!isManager && value == 0) {
              final gDiskon =
                  _keranjangController.getDiskon(produk['kode_produk']);

              _keranjangController.langsungtambahkeKeranjang(
                  sisa,
                  produk,
                  gDiskon['diskon'] ?? 0,
                  gDiskon['min_produk'],
                  gDiskon['grosir'] ?? 'Normal');
            } else if (value == 1) {
              final sisa = produk['stok'] - produk['terjual'];
              if (sisa > 0) {
                Get.dialog(DialogJual(loadProduk: produk));
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

    void refreshgambar() {
      if (controller.isNeedRefreshProduk.value) {
        produk['gambar'] =
            controller.refreshProdukUpdate(produk['kode_produk']);
        controller.isNeedRefreshProduk.value = false;
      }
    }

    controller.kategoriAdd.value = produk['kategori'];
    final listPictures = produk.isNotEmpty && produk['gambar'] is List
        ? List.from(produk['gambar'] ?? []).obs
        : [].obs;
    // print(listPictures);
    Get.to(() => NewProduct(
          listPictures: listPictures,
          produkEdit: produk,
          refreshGambar: refreshgambar,
        ));
  }
}
