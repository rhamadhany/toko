import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class IconSave extends StatelessWidget {
  const IconSave({
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
    return IconButton(
      onPressed: () async {
        try {
          String product =
              _productController.listTextField[0]['controller'].text;
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
          final kategori = _productController.kategoriAdd.value;
          final deskripsi =
              _productController.listTextField[5]['controller'].text;
          List<Map<String, dynamic>> listGambar = [];
          if (listPictures.isNotEmpty) {
            for (var (gambar as String) in listPictures) {
              Uint8List? bytes;
              String ext = '.jpeg';

              if (gambar.startsWith('/data')) {
                bytes = await File(gambar).readAsBytes();
                ext = gambar.split('.').last;
              } else if (gambar.startsWith('blob')) {
                final response = await http.get(Uri.parse(gambar));
                bytes = response.bodyBytes;

                final String mimeType =
                    lookupMimeType('blob', headerBytes: bytes) ?? 'image/jpeg';

                ext = mimeType.split('/').last;
              } else {
                final url = Uri.parse('$domain/produk/load_gambar.php');
                final response =
                    (await http.post(url, body: {'gambar': gambar}));
                if (response.statusCode == 200) {
                  final base64 = jsonDecode(response.body);
                  bytes = base64Decode(base64);
                }
                ext = gambar.split('.').last;
              }
              final base64 = base64Encode(bytes!);
              final random =
                  '${DateTime.now().millisecondsSinceEpoch}_${Uuid().v4()}';
              final name = '$random.$ext';
              // print('name $name');
              listGambar.add({'nama': name, 'base64': base64});
            }
          }

          // print(listGambar);
          if (produkEdit.isNotEmpty) {
            produkEdit['gambar'] = listGambar;
            produkEdit['produk'] = product;
            produkEdit['harga_beli'] = hargaBeli;
            produkEdit['harga_jual'] = hargaJual;
            produkEdit['terjual'] = terjual;
            produkEdit['stok'] = stock;
            produkEdit['kategori'] = kategori;
            produkEdit['deskripsi'] = deskripsi;

            await DBHelper.updateProduct(produkEdit, true);
          } else {
            await DBHelper.addProduct(product, hargaBeli, hargaJual, terjual,
                stock, listGambar, kategori, deskripsi);
          }
          _productController.isNeedRefreshProduk.value = true;
          Get.back();
        } catch (e) {
          SnackHelper.snackError(content: 'Error inisiasi produk');
        }
      },
      icon: const Icon(Icons.check),
    );
  }
}
