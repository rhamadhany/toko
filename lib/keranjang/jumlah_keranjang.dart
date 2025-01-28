import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/keranjang_controller.dart';

class JumlahKeranjang extends StatelessWidget {
  JumlahKeranjang(
      {super.key,
      required this.jumlahControllers,
      required this.indexKeranjang});
  final KeranjangController _keranjangController = Get.find();
  final List<TextEditingController> jumlahControllers;
  final int indexKeranjang;

  @override
  Widget build(BuildContext context) {
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
            child: TextField(
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              controller: jumlahControllers[indexKeranjang],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(5),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  // jumlahControllers[indexKeranjang].text = '1';
                  final keyUpdate = _keranjangController
                      .keranjangProduk[indexKeranjang]['key'];
                  final newJumlah = int.tryParse(value) ??
                      _keranjangController.keranjangProduk[indexKeranjang]
                          ['jumlah'];
                  _keranjangController.updateJumlah(keyUpdate, newJumlah);
                }
              },
            ),
          ),
        ),
        IconButton(
            iconSize: 12,
            onPressed: () {
              jumlahCount(indexKeranjang, true);
            },
            icon: const Icon(
              Icons.add,
            )),
      ],
    );
  }

  void jumlahCount(int indexKeranjang, bool tambah) {
    int jumlah = int.tryParse(jumlahControllers[indexKeranjang].text) ?? 1;
    int newJumlah = 0;
    if (tambah) {
      newJumlah = jumlah + 1;
    } else {
      newJumlah = jumlah > 1 ? jumlah - 1 : 1;
    }

    final keyUpdate =
        _keranjangController.keranjangProduk[indexKeranjang]['key'];
    _keranjangController.updateJumlah(keyUpdate, newJumlah);
    jumlahControllers[indexKeranjang].text = newJumlah.toString();
  }
}
