import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/home/appbar_my_app.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:myapp/pengaturan/printing_qr.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:myapp/produk%20baru/produk_baru.dart';

class PageProdukAdmin extends GetView<ManagerController> {
  PageProdukAdmin({super.key});

  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  @override
  Widget build(BuildContext context) {
    if (!Settings.autentikasiAktif.value) {
      controller.requestPassword();
    } else {
      controller.inisiasiAuthController();
    }
    return Obx(() {
      return PopScope(
        canPop: !_productController.showCheckBoxRemove.value,
        onPopInvokedWithResult: (_, __) {
          if (_productController.showCheckBoxRemove.value) {
            _productController.showCheckBoxRemove.value = false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.shop),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'PRODUK',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Spacer(),
                if (!_productController.showCheckBoxRemove.value)
                  dynamicIconAppBar(_productController, true),
                if (_productController.showCheckBoxRemove.value)
                  IconButton(
                      onPressed: () {
                        PrintingQR(dariBox: true.obs).dialogQR();
                      },
                      icon: Icon(Icons.print)),
                if (_productController.showCheckBoxRemove.value)
                  IconButton(
                      onPressed: () {
                        for (int i = 0;
                            i < _productController.mapCheckBoxRemove.length;
                            i++) {
                          _productController.mapCheckBoxRemove[i]
                              ['isSelected'] = _productController
                                      .mapCheckBoxRemove[i]['isSelected'] ==
                                  'true'
                              ? 'false'
                              : 'true';

                          _productController.mapCheckBoxRemove.refresh();
                        }
                      },
                      icon: const Icon(Icons.select_all, color: Colors.white)),
              ],
            ),
          ),
          body: !_biometrikController.hasAuthenticated.value
              ? null
              : HomeToko(isManager: true),
          floatingActionButton: !_biometrikController.hasAuthenticated.value &&
                  Settings.autentikasiAktif.value
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                ))
              : FloatingActionButton(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    if (_productController.showCheckBoxRemove.value &&
                        _productController.filterProduct.isNotEmpty) {
                      final existSelect = _productController.mapCheckBoxRemove
                          .any((any) => any['isSelected'] == 'true');

                      if (!existSelect) {
                        Get.snackbar("Error", "Pilih setidaknya 1 produk",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.white,
                            backgroundColor: Colors.red);
                        return;
                      }

                      bool? confirm = await controller.confirmationDelete();
                      if (!confirm) {
                        return;
                      }
                      List<String> listKey = [];
                      for (int i = 0;
                          i < _productController.filterProduct.length;
                          i++) {
                        if (_productController.mapCheckBoxRemove[i]
                                    ['isSelected'] ==
                                'true' &&
                            _productController.mapCheckBoxRemove[i]
                                    ['kode_produk'] !=
                                "") {
                          listKey.add(_productController.mapCheckBoxRemove[i]
                              ['kode_produk']!);
                        }
                      }

                      await _keranjangController.removeProduk(listKey);

                      await DBHelper.deleteProduct(listKey);
                      await _keranjangController.loadProduk();
                      await _productController.generateMapCheckBox();
                    } else {
                      _productController.kategoriAdd.value = 'Semua';
                      for (final controller
                          in _productController.listTextField) {
                        if (controller['label'] != 'Terjual') {
                          controller['controller'].clear();
                        } else {
                          controller['controller'].text = "0";
                        }
                      }

                      Get.to(() => NewProduct());
                    }
                  },
                  child: Icon(
                    _productController.showCheckBoxRemove.value &&
                            _productController.filterProduct.isNotEmpty
                        ? Icons.clear
                        : Icons.add,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    });
  }
}
