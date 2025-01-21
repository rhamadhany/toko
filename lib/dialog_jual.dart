import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/product_controller.dart';

class DialogJual extends StatelessWidget {
  DialogJual({super.key, required this.produk});
  final ProductController _productController = Get.find();
  final RxMap<String, dynamic> produk;
  final RxBool showSnackbarStok = false.obs;
  final RxBool finishLongPress = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AlertDialog(
        title: const Text("Jual Produk"),
        content: Row(
          children: [
            GestureDetector(
              onLongPressStart: (_) async {
                finishLongPress.value = false;
                await countJual(false, true);
              },
              onLongPressEnd: (_) {
                finishLongPress.value = true;
              },
              onTap: () async {
                await countJual(false, false);
              },
              child: const Icon(
                Icons.remove_circle,
                size: 30,
              ),
            ),
            Expanded(
              child: TextField(
                textAlign: TextAlign.center,
                controller: _productController.jualController.value,
                keyboardType: TextInputType.number,
              ),
            ),
            GestureDetector(
              onLongPressStart: (_) async {
                finishLongPress.value = false;
                await countJual(true, true);
              },
              onLongPressEnd: (_) {
                finishLongPress.value = true;
              },
              onTap: () async {
                await countJual(true, false);
              },
              child: const Icon(
                Icons.add_circle,
                size: 30,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () async {
                final count = _productController.jualController.value.text;
                int countInt = int.parse(count);

                final sisa = produk['stok'] - (produk['terjual'] + countInt);
                // print(sisa);

                if (sisa > -1) {
                  final terjualSebelumnya = produk['terjual'];

                  final terjualBaru =
                      int.parse(_productController.jualController.value.text);

                  produk['terjual'] = terjualSebelumnya + terjualBaru;
                  Get.back();
                  await _productController.updateProduct(produk);
                } else {
                  await stokTidakCukup(true);
                  // _productController.jualController.value.clear();
                  // print(sisa);
                }
              },
              child: const Text("Jual"))
        ],
      );
    });
  }

  Future countJual(bool add, bool longpress) async {
    String count = _productController.jualController.value.text;
    int countInt = int.parse(count);
    int sisa = produk['stok'] - (produk['terjual'] + countInt);

    nilaiSisa() {
      count = _productController.jualController.value.text;
      countInt = int.parse(count);

      sisa = produk['stok'] - (produk['terjual'] + countInt);
    }

    try {
      if (add && !longpress) {
        if (sisa > 0) {
          countInt++;
        } else {
          await stokTidakCukup(false);
        }
      } else if (add && longpress) {
        if (sisa > 0) {
          Timer.periodic(const Duration(milliseconds: 100), (timer) async {
            if (sisa < 1) {
              await stokTidakCukup(false);
              timer.cancel();
              return;
            }
            if (finishLongPress.value) {
              timer.cancel();
              return;
            }
            countInt++;
            _productController.jualController.value.text = countInt.toString();
            nilaiSisa();
          });
        } else {
          await stokTidakCukup(false);
        }
      } else if (!add && !longpress) {
        if (countInt > 0) {
          countInt--;
        }
      } else if (!add && longpress) {
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (countInt < 1) {
            timer.cancel();
            return;
          }
          if (finishLongPress.value) {
            timer.cancel();
            return;
          }
          countInt--;
          _productController.jualController.value.text = countInt.toString();

          nilaiSisa();
        });
      }
      _productController.jualController.value.text = countInt.toString();
    } catch (e) {
      _productController.jualController.value.text = "0";
    }
  }

  Future<void> stokTidakCukup(bool isJual) async {
    if (!showSnackbarStok.value) {
      Get.snackbar("Stok",
          "${produk['produk']} hanya tersisa ${produk['stok'] - produk['terjual']} produk",
          snackPosition: SnackPosition.BOTTOM);
      showSnackbarStok.value = true;
      if (isJual) {
        _productController.jualController.value.text =
            (produk['stok'] - produk['terjual']).toString();
      }

      await Future.delayed(const Duration(seconds: 3));
      showSnackbarStok.value = false;
    }
  }
}
