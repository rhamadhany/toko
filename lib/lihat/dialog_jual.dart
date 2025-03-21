import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/lihat/button_dialog_jual_helper.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';
import 'package:myapp/lihat/dialog_list_grosir.dart';
import 'package:myapp/lihat/grosir_helper.dart';

class DialogJual extends StatelessWidget
    with DialogJualHelper, ButtonDialogJualHelper {
  DialogJual({super.key, required this.loadProduk});
  final RxMap<String, dynamic> loadProduk;

  @override
  Widget build(BuildContext context) {
    jualController.value.text = '0';
    DialogJualHelper.selectedGrosir.value = Map<String, dynamic>.from(
        GetStorage().read('selectedGrosir') ?? defaultSelectedGrosir);

    return Obx(() {
      produk.value = loadProduk;

      return AlertDialog(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        title: Text(produk['produk'].toUpperCase()),
        content: IntrinsicHeight(
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onLongPress: () async {
                      while (!finishLongPress.value) {
                        final count = jualController.value.text;
                        int countInt = int.tryParse(count) ?? 0;
                        countInt--;
                        await countJual(countInt);
                        await Future.delayed(const Duration(milliseconds: 100));
                      }
                    },
                    onLongPressStart: (_) async {
                      finishLongPress.value = false;
                    },
                    onLongPressEnd: (_) async {
                      finishLongPress.value = true;
                    },
                    onTap: () async {
                      final count = jualController.value.text;
                      int countInt = int.tryParse(count) ?? 0;
                      countInt--;
                      await countJual(countInt);
                    },
                    child: const Icon(
                      Icons.remove_circle,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: jualController.value,
                      keyboardType: TextInputType.number,
                      onChanged: (value) async {
                        final count = jualController.value.text;
                        int countInt = int.tryParse(count) ?? 0;

                        await countJual(countInt);
                      },
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () async {
                      while (!finishLongPress.value) {
                        final count = jualController.value.text;
                        int countInt = int.tryParse(count) ?? 0;
                        countInt++;
                        await countJual(countInt);
                        await Future.delayed(const Duration(milliseconds: 100));
                      }
                    },
                    onLongPressStart: (_) async {
                      finishLongPress.value = false;
                    },
                    onLongPressEnd: (_) async {
                      finishLongPress.value = true;
                    },
                    onTap: () async {
                      final count = jualController.value.text;
                      int countInt = int.tryParse(count) ?? 0;
                      countInt++;

                      await countJual(countInt);
                    },
                    child: const Icon(
                      Icons.add_circle,
                      size: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Card(
                color: Colors.blue,
                child: ListTile(
                  leading: Icon(
                    Icons.discount,
                    color: Colors.white,
                  ),
                  title: Text(
                    DialogJualHelper.selectedGrosir.isEmpty
                        ? 'Diskon'
                        : DialogJualHelper.selectedGrosir['nama'],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Obx(() {
                    return Text(
                      'Rp ${totalHargaPotongan().value}',
                      style: TextStyle(color: Colors.white),
                    );
                  }),
                  onTap: () {
                    Get.dialog(DialogListGrosir());
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Rp ${totalHargaSetelahDiskon().value}',
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
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
                  pressKeranjang();
                },
                child: const Icon(Icons.shopping_cart)),
          ),
          Tooltip(
            message: "Jual",
            child: ElevatedButton(
              onPressed: () async {
                await pressJual();
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
}
