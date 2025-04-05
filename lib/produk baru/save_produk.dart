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
    this.refreshGambar,
  }) : _productController = productController;

  final ProductController _productController;
  final RxMap<String, dynamic> produkEdit;
  final RxList listPictures;
  final Function? refreshGambar;

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
          final listGambar = [];

          final listOld = produkEdit.isNotEmpty && produkEdit['gambar'] is List
              ? List.from(produkEdit['gambar'] ?? [])
              : [];
          if (listOld.isNotEmpty) {
            await deleteOldImageServer(listPictures, listOld);
          }
          if (listPictures.isNotEmpty) {
            for (var item in listPictures) {
              final gambar = item['name'];
              final ada = listOld.any((a) {
                return a['name'] == gambar;
              });
              // final listdelete = listOld.where((a) => a['name'] != gambar);

              // for (var d in listdelete) {
              //   print(d['name']);
              // }
              if (!ada) {
                Uint8List? bytes;
                String? extGambar;
                if (gambar.startsWith('blob:')) {
                  final response = await http.get(Uri.parse(gambar));
                  if (response.statusCode == 200) {
                    bytes = response.bodyBytes;
                    extGambar = (lookupMimeType('blob', headerBytes: bytes) ??
                            'image/jpeg')
                        .split('/')
                        .last;
                  }
                } else {
                  bytes = await File(gambar).readAsBytes();
                  extGambar = gambar.split('.').last;
                }
                final random =
                    '${DateTime.now().millisecondsSinceEpoch}_${Uuid().v4()}';
                final nama = '$random.${extGambar ?? 'jpeg'}';

                final url = Uri.parse('$domain/upload_gambar');
                final response = await http.post(url, body: {
                  'gambar': base64Encode(bytes!),
                  'nama': nama,
                });
                if (response.statusCode == 200) {
                  // print(response.body);
                  final encode = jsonDecode(response.body);
                  // print(encode);
                  if (encode['status'] == 'sukses') {
                    listGambar.add(encode['gambar']);
                  }
                }
              } else {
                listGambar.add(gambar);
              }
            }
          }

          final encodeListGambar = jsonEncode(listGambar);
          // print(encodeListGambar);
          if (produkEdit.isNotEmpty) {
            final newProduk = produkEdit;

            newProduk['gambar'] = encodeListGambar;

            newProduk['produk'] = product;
            newProduk['harga_beli'] = hargaBeli;
            newProduk['harga_jual'] = hargaJual;
            newProduk['terjual'] = terjual;
            newProduk['stok'] = stock;
            newProduk['kategori'] = kategori;
            newProduk['deskripsi'] = deskripsi;

            await DBHelper.updateProduct(newProduk, true);
          } else {
            await DBHelper.addProduct(product, hargaBeli, hargaJual, terjual,
                stock, encodeListGambar, kategori, deskripsi);
          }
          _productController.isNeedRefreshProduk.value = true;
          if (refreshGambar != null) {
            refreshGambar!();
          }
          Get.back();
        } catch (e, straceStack) {
          debugPrint('error $e $straceStack');
          SnackHelper.snackError(content: 'Error inisiasi produk');
        }
      },
      icon: const Icon(Icons.check),
    );
  }

  Future<void> deleteOldImageServer(List listPictures, List listOld) async {
    try {
      if (listOld.isNotEmpty) {
        final delete = listOld
            .where((a) {
              return !listPictures.any((b) => b['name'] == a['name']);
            })
            .map((c) => c['name'])
            .toList();
        final encodeDelete = jsonEncode(delete);
        await http.post(Uri.parse('$domain/hapus_gambar'),
            body: {'gambar': encodeDelete});
      }
    } catch (e) {
      debugPrint('Error delete image in server $e');
    }
  }
}
