import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/db_helper.dart';

class GenerateItem extends StatelessWidget {
  GenerateItem({super.key});

  final jumlahItem = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: TextField(
                textAlign: TextAlign.center,
                controller: jumlahItem,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(label: Text('Jumlah Generate')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final jumlah = int.tryParse(jumlahItem.text) ?? 0;
          generateCall(jumlah);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  static Future<void> generateCall(int nilaiRandom) async {
    Get.back();
    Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          backgroundColor: Colors.transparent,
          content: SizedBox(
            height: Get.height,
            width: Get.width,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ));

    for (int i = 0; i < nilaiRandom; i++) {
      final namaRandom = 'Nama Item $i';
      final hargaBeliRandom = Random().nextInt(100000);
      final hargaJualRandom = hargaBeliRandom + (hargaBeliRandom * 0.2).toInt();
      final stokRandom = Random().nextInt(100);

      await DBHelper.addProduct(
          namaRandom,
          hargaBeliRandom.toString(),
          hargaJualRandom.toString(),
          0,
          stokRandom,
          RxList<dynamic>.empty(),
          'Semua',
          '');
    }
    Get.back();
    Get.snackbar("Berhasil", "$nilaiRandom random ditambahkan ke daftar produk",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.blue);
  }

  static ElevatedButton textGenerate() {
    return ElevatedButton(
      onPressed: () {
        Get.to(() => GenerateItem());
      },
      child: const Text('Generate'),
    );
  }
}
