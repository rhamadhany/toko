import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/keranjang/body_keranjang.dart';
import 'package:myapp/keranjang/app_bar_row.dart';
import 'package:myapp/keranjang/bottom_bar.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';

class HalamanKeranjang extends StatelessWidget {
  const HalamanKeranjang({super.key, required this.isManager});
  static final KeranjangController _keranjangController = Get.find();
  final bool isManager;
  @override
  Widget build(BuildContext context) {
    _keranjangController.initValueBox();
    // initValueBox();
    // return Obx(() {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _keranjangController.valueBox.value = List.generate(
            _keranjangController.valueBox.length, (index) => false);

        // _keranjangController.jumlahControllers.clear();
        // _keranjangController.hargaJual.clear();
      },
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              title: AppBarRow(
                isManager: isManager,
              )),
          body: BodyKeranjang(),
          bottomNavigationBar: const BottomBar()),
    );
    // });
  }

  static bool haveValueBox() {
    return _keranjangController.valueBox.any((any) => any == true);
  }
}

mixin class KeranjangHelper {
  final _productController = Get.find<ProductController>();

  String? gambarIndex(
    Map<String, dynamic> produk,
  ) {
    final indexKey = _productController.allProduct
        .indexWhere((semua) => semua['kode_produk'] == produk['kode_produk']);

    if (indexKey != -1) {
      final gambar = _productController.allProduct[indexKey]['gambar'];
      if (gambar is List && gambar.isNotEmpty) {
        return gambar[0];
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  Text hargaBarang(String keyKeranjang) {
    final indexKeys = _productController.allProduct
        .indexWhere((product) => product['kode_produk'] == keyKeranjang);
    final harga = indexKeys != -1
        ? _productController.allProduct[indexKeys]['harga_jual']
        : 0;
    final hargaFinal = _productController.regexNominal(harga.toString());
    return Text(
      "Rp $hargaFinal",
      style: const TextStyle(
          color: Colors.deepOrangeAccent, fontSize: kIsWeb ? 24 : 12),
    );
  }

  String sisa(String keyKeranjang) {
    final indexKeys = _productController.allProduct
        .indexWhere((product) => product['kode_produk'] == keyKeranjang);
    if (indexKeys != -1) {
      final sisa = _productController.allProduct[indexKeys]['stok'] -
          _productController.allProduct[indexKeys]['terjual'];
      return sisa.toString();
    }
    return '0';
  }
}
