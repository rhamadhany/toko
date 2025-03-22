import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';
// import 'package:myapp/pengaturan/biometrik.dart';

class JumlahKeranjang extends StatelessWidget {
  JumlahKeranjang(
      {super.key,
      // required this.jumlahControllers,
      required this.indexKeranjang});
  final KeranjangController _keranjangController = Get.find();
  // final RxList<TextEditingController> jumlahControllers;
  final int indexKeranjang;

  @override
  Widget build(BuildContext context) {
    // return Obx(() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            iconSize: 12,
            onPressed: () {
              jumlahCount(indexKeranjang, false);
            },
            icon: const Icon(Icons.remove)),
        IntrinsicWidth(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 50),
              child: Obx(
                () => TextField(
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  controller: _keranjangController.valueBox[indexKeranjang]
                      ['controller'],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(5),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      // jumlahControllers[indexKeranjang].text = '1';
                      final keyUpdate = _keranjangController
                          .keranjangProduk[indexKeranjang]['kode_produk'];
                      final newJumlah = int.tryParse(value) ??
                          _keranjangController.keranjangProduk[indexKeranjang]
                              ['jumlah'];
                      final diskon = _keranjangController
                          .keranjangProduk[indexKeranjang]['diskon'];
                      final minProduk = _keranjangController
                          .keranjangProduk[indexKeranjang]['min_produk'];
                      _keranjangController.updateJumlah(
                          keyUpdate, newJumlah, diskon, minProduk);

                      final sisa =
                          _keranjangController.sisaPadaAllProduk(keyUpdate);
                      if (newJumlah > sisa) {
                        _keranjangController
                                .valueBox[indexKeranjang]['controller'].text =
                            _keranjangController.keranjangProduk[indexKeranjang]
                                    ['jumlah']
                                .toString();
                        _keranjangController.valueBox.refresh();
                      }
                    }
                  },
                ),
              )),
        ),
        IconButton(
            iconSize: 12,
            onPressed: () async {
              await jumlahCount(indexKeranjang, true);
            },
            icon: const Icon(
              Icons.add,
            )),
      ],
    );
    // });
  }

  Future<void> jumlahCount(int indexKeranjang, bool tambah) async {
    int jumlah = int.tryParse(
            _keranjangController.valueBox[indexKeranjang]['controller'].text) ??
        1;
    int newJumlah = 0;
    if (tambah) {
      newJumlah = jumlah + 1;
    } else {
      newJumlah = jumlah > 1 ? jumlah - 1 : 1;
    }

    final keyUpdate =
        _keranjangController.keranjangProduk[indexKeranjang]['kode_produk'];
    final diskon =
        _keranjangController.keranjangProduk[indexKeranjang]['diskon'];
    final minProduk =
        _keranjangController.keranjangProduk[indexKeranjang]['min_produk'];
    await _keranjangController.updateJumlah(
        keyUpdate, newJumlah, diskon, minProduk);
    _keranjangController.valueBox[indexKeranjang]['controller'].text =
        _keranjangController.keranjangProduk[indexKeranjang]['jumlah']
            .toString();
  }
}
