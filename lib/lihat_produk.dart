import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/dialog_jual.dart';
import 'package:myapp/gambar_penuh.dart';
import 'package:myapp/logo_produk.dart';
import 'package:myapp/produk_baru.dart';
import 'package:myapp/product_controller.dart';

class LihatProduk extends StatelessWidget {
  LihatProduk({super.key, required this.produk});
  final RxMap<String, dynamic> produk;
  final ProductController _productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
            title: Text(
          '${produk['produk']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (produk['gambar'].toString() == '[]') noLogoProduk(300),
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
                            child: logoProduk(picPath, 300, 2.5));
                      })
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Rp ${_productController.hargaProduk(produk)}",
                        style: const TextStyle(
                            fontSize: 26,
                            color: Colors.deepOrangeAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Terjual: ${produk['terjual']}/${produk['stok']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      sisaProduk()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Edit'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_shopping_cart), label: 'Jual'),
          ],
          currentIndex: _productController.bottomIndex.value,
          onTap: (value) {
            _productController.bottomIndex.value = value;
            if (value == 0) {
              editProduk();
            } else {
              final sisa = produk['stok'] - produk['terjual'];
              if (sisa > 0) {
                _productController.jualController.value.text = '0';
                Get.dialog(DialogJual(
                  produk: produk,
                ));
              } else {
                Get.snackbar("Stok", "${produk['produk']} kosong",
                    snackPosition: SnackPosition.BOTTOM);
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

  sisaProduk() {
    final sisa = produk['stok'] - produk['terjual'];
    return Text(
      sisa > 0 ? "Sisa: $sisa" : "",
      style: const TextStyle(fontSize: 18),
    );
  }
}
