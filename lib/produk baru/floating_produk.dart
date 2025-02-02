import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/db_helper.dart';

class FloatingProduk extends StatelessWidget {
  const FloatingProduk({
    super.key,
    required ProductController productController,
    required this.produkEdit,
    required this.listPictures,
  }) : _productController = productController;

  final ProductController _productController;
  final RxMap<String, dynamic> produkEdit;
  final RxList listPictures;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        String product = _productController.listTextField[0]['controller'].text;
        String hargaBeli =
            _productController.listTextField[1]['controller'].text;
        String hargaJual =
            _productController.listTextField[2]['controller'].text;
        int? terjual = int.tryParse(
                _productController.listTextField[3]['controller'].text) ??
            0;
        int? stock = int.tryParse(
                _productController.listTextField[4]['controller'].text) ??
            0;

        if (produkEdit.isNotEmpty) {
          produkEdit['gambar'] = listPictures;
          produkEdit['produk'] = product;
          produkEdit['harga_beli'] = hargaBeli;
          produkEdit['harga_jual'] = hargaJual;
          produkEdit['terjual'] = terjual;
          produkEdit['stok'] = stock;

          await DBHelper.updateProduct(produkEdit);
        } else {
          await DBHelper.addProduct(
              product, hargaBeli, hargaJual, terjual, stock, listPictures);
        }

        Get.back();
      },
      child: const Icon(Icons.check),
    );
  }
}
