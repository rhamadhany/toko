import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/splash_controller.dart';

import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/keranjang/halaman_keranjang.dart';
import 'package:myapp/manager/manager_toko.dart';

class AppBarMyApp extends StatelessWidget {
  const AppBarMyApp({super.key, required this.isManager});

  final bool isManager;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () {
            Get.to(() => MenuManager());
          },
          icon: Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
          ),
          label: Text(
            Get.find<SplashController>().username.value.toUpperCase(),
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const Spacer(),
        IconAppBarHome(
          isManager: isManager,
        )
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

class IconAppBarHome extends GetView<ProductController> {
  IconAppBarHome({super.key, required this.isManager});

  final bool isManager;
  final KeranjangController _keranjangController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              controller.showSearch.value = !controller.showSearch.value;

              if (!controller.showSearch.value) {
                controller.searchText.value = '';
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
            icon: Stack(
              alignment: Alignment.topRight,
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                Positioned(
                  top: -5,
                  right: _keranjangController.keranjangProduk.length > 99
                      ? -5
                      : -0,
                  child: Container(
                    // constraints: BoxConstraints(minHeight: 30, minWidth: 30),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Obx(() => Text(
                            (_keranjangController.keranjangProduk.length > 99
                                    ? '99+'
                                    : _keranjangController
                                        .keranjangProduk.length)
                                .toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          )),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
