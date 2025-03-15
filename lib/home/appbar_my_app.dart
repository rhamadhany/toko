import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';

class AppBarMyApp extends StatelessWidget {
  AppBarMyApp({super.key, required this.isManager});

  final ProductController _productController = Get.find();
  final bool isManager;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "PRODUK",
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        dynamicIconAppBar(_productController, isManager),
      ],
    );
  }

  pilihBulan() {
    Get.dialog(AlertDialog(
      content: SizedBox(
        height: 200,
        child: CupertinoPicker(
            itemExtent: 30,
            onSelectedItemChanged: (int value) {},
            children: List.generate(12, (index) {
              return Text(index.toString());
            })),
      ),
    ));
  }
}

Row dynamicIconAppBar(ProductController productController, bool isManager) {
  return Row(
    children: [
      IconButton(
          onPressed: () {
            productController.showSearch.value =
                !productController.showSearch.value;

            if (!productController.showSearch.value) {
              productController.searchText.value = '';
              HomeToko.focusPencarian.requestFocus();
            }
          },
          icon: const Icon(Icons.search, color: Colors.white)),
      IconButton(
          onPressed: () {
            Get.to(() => HalamanKeranjang(
                  isManager: isManager,
                ));
          },
          icon: const Icon(
            Icons.shopping_cart_checkout,
            color: Colors.white,
          )),
    ],
  );
}
