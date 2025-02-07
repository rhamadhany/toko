import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/transaksi_controller.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/settings.dart';

class DialogJual extends StatelessWidget {
  DialogJual({super.key, required this.produk});
  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController = Get.find();
  final LaporanController _laporanController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final TransaksiController _transaksiController = Get.find();
  final RxMap<String, dynamic> produk;
  final RxBool showSnackbarStok = false.obs;
  final RxBool finishLongPress = false.obs;
  @override
  Widget build(BuildContext context) {
    _biometrikController.hasAuthenticated.value = false;

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
          Tooltip(
            message: "Keranjang",
            child: ElevatedButton(
                onPressed: () {
                  int jumlah = int.tryParse(
                          _productController.jualController.value.text) ??
                      1;
                  final sisa = produk['stok'] - produk['terjual'];

                  if (jumlah <= sisa) {
                    if (jumlah == 0) {
                      jumlah = 1;
                    }
                    final gambar =
                        produk['gambar'].isEmpty ? "" : produk['gambar'][0];
                    _keranjangController.addProduk(
                        produk['key'], produk['produk'], jumlah, gambar);

                    Get.back(closeOverlays: true);
                    Get.back(closeOverlays: true);
                    HomeToko.focusPencarian.unfocus();
                    Get.snackbar('Keranjang',
                        '$jumlah ${produk['produk']} ditambahkan ke keranjang',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.blue,
                        duration: const Duration(seconds: 1));
                  } else {
                    Get.snackbar("Tidak Cukup",
                        "${produk['produk']} hanya tersisa $sisa",
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 1));
                    _productController.jualController.value.text =
                        sisa.toString();
                  }
                },
                child: const Icon(Icons.shopping_cart)),
          ),
          Tooltip(
            message: "Jual",
            child: ElevatedButton(
              onPressed: () async {
                if (Settings.autentikasiAktif.value) {
                  final hasAuth = await _biometrikController.authReuired();
                  if (hasAuth) {
                    _biometrikController.hasAuthenticated.value = true;
                  }
                  if (!_biometrikController.hasAuthenticated.value) {
                    Get.snackbar('Gagal', 'Autentikasi gagal',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.red);
                    return;
                  }
                }

                final count = _productController.jualController.value.text;
                int countInt = int.parse(count);

                final sisa = produk['stok'] - (produk['terjual'] + countInt);

                if (sisa > -1) {
                  final terjualSebelumnya = produk['terjual'];

                  final terjualBaru =
                      int.parse(_productController.jualController.value.text);
                  if (terjualBaru <= 0) {
                    Get.snackbar('Gagal', 'Masukkan jumlah yang dijual',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 1));
                    return;
                  }

                  produk['terjual'] = terjualSebelumnya + terjualBaru;
                  final key = produk['key'];
                  Get.back(closeOverlays: true);
                  Get.back(closeOverlays: true);
                  HomeToko.focusPencarian.unfocus();
                  await DBHelper.updateProduct(produk, false);
                  _laporanController.tambahJual(key, terjualBaru, 'penjualan');
                  final item = _productController.allProduct
                      .where((im) => im['key'] == key)
                      .first;
                  final hBeli = int.tryParse(item['harga_beli'])!;
                  final hJual = int.tryParse(item['harga_jual'])!;
                  final modal = hBeli * terjualBaru;
                  final omset = hJual * terjualBaru;
                  final laba = omset - modal;
                  final List<String> listKey = [];
                  listKey.add(key);
                  await _transaksiController.addTransaksi(
                      terjualBaru, listKey, modal, omset, laba);
                  Get.snackbar('Terjual',
                      '$terjualBaru ${produk['produk']} telah dijual',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 1));
                } else {
                  await stokTidakCukup(true);
                }
              },
              child: const Icon(
                Icons.shopping_cart_checkout,
              ),
            ),
          )
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
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1));
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
