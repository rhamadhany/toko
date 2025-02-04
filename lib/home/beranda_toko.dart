import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/pengaturan/biometrik.dart';

import 'package:myapp/lihat/lihat_produk.dart';
import 'package:myapp/lihat/logo_produk.dart';
import 'package:myapp/controller/product_controller.dart';

class HomeToko extends StatelessWidget {
  HomeToko({
    super.key,
  });
  final BiometrikController _biometrikController = Get.find();
  final ProductController _productController = Get.find();
  static final focusPencarian = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            if (_productController.showSearch.value)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
                child: TextField(
                  autofocus: true,
                  controller: _productController.pencarianController,
                  focusNode: focusPencarian,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          focusPencarian.unfocus();
                          await Future.delayed(const Duration(seconds: 1));
                          Get.to(() => QRScanner(
                                dariKeranjang: false,
                              ));
                        },
                        icon: const Icon(
                          Icons.qr_code_scanner,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: "Cari Produk",
                      labelText: "Cari Produk"),
                  onChanged: (value) {
                    _productController.searchText.value = value;
                  },
                ),
              ),
            if (_productController.allProduct.isNotEmpty &&
                _productController.daftarKategori.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ..._productController.daftarKategori
                          .map((kategori) => Card(
                                color: kategori['kategori'] ==
                                        _productController.kategoriAktif.value
                                    ? Colors.blue
                                    : null,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      _productController.kategoriAktif.value =
                                          kategori['kategori'];
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          IconData(kategori['icon'],
                                              fontFamily: 'MaterialIcons'),
                                          color: kategori['kategori'] ==
                                                  _productController
                                                      .kategoriAktif.value
                                              ? Colors.white
                                              : null,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          kategori['kategori'],
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: kategori['kategori'] ==
                                                      _productController
                                                          .kategoriAktif.value
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ))
                    ],
                  ),
                ),
              ),
            if (_productController.filterProduct.isEmpty) const Spacer(),
            _productController.filterProduct.isEmpty
                ? Center(
                    child: Icon(
                    Icons.shop,
                    size: Get.height * 0.3,
                  )
                    //   Text(
                    //   "Tidak ada produk",
                    //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    // )

                    )
                : Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _productController.filterProduct.length,
                      itemBuilder: (context, indexProduct) {
                        final listProduk =
                            _productController.filterProduct[indexProduct].obs;

                        final terjual = listProduk['terjual'];
                        final stok = listProduk['stok'];
                        final sisa = stok - terjual;
                        return InkWell(
                          onTap: () {
                            if (_productController.showCheckBoxRemove.value) {
                              bool isChecked = _productController
                                          .mapCheckBoxRemove[indexProduct]
                                      ['isSelected'] ==
                                  'true';
                              isChecked = !isChecked;

                              _productController.mapCheckBoxRemove[indexProduct]
                                      ['isSelected'] =
                                  isChecked
                                      ? true.toString()
                                      : false.toString();

                              _productController.mapCheckBoxRemove.refresh();
                            } else {
                              Get.to(() => LihatProduk(produk: listProduk));
                            }
                          },
                          onLongPress: () async {
                            if (_biometrikController.tabIndex.value == 1) {
                              _productController.showCheckBoxRemove.value =
                                  !_productController.showCheckBoxRemove.value;
                              if (_productController.showCheckBoxRemove.value) {
                                await _productController.generateMapCheckBox();
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      if (listProduk['gambar'].isNotEmpty)
                                        logoProduk(listProduk['gambar'][0],
                                            sisa, 200, 2.5),
                                      if (listProduk['gambar'].isEmpty)
                                        noLogoProduk(170, sisa),
                                      if (_productController
                                              .showCheckBoxRemove.value &&
                                          _biometrikController.tabIndex.value ==
                                              1)
                                        Obx(() {
                                          final isChecked = RxBool(
                                              _productController
                                                              .mapCheckBoxRemove[
                                                          indexProduct]
                                                      ['isSelected'] ==
                                                  'true');

                                          return Positioned(
                                            top: -8,
                                            right: -8,
                                            child: Transform.scale(
                                              scale: 1.2,
                                              child: Checkbox(
                                                activeColor: Colors.blue,
                                                value: isChecked.value,
                                                onChanged: (value) {
                                                  _productController
                                                                  .mapCheckBoxRemove[
                                                              indexProduct]
                                                          ['isSelected'] =
                                                      value.toString();

                                                  _productController
                                                      .mapCheckBoxRemove
                                                      .refresh();
                                                },
                                              ),
                                            ),
                                          );
                                        })
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listProduk['produk'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(
                                        "Rp ${_productController.hargaProduk(listProduk)}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Terjual ${listProduk['terjual']}/${listProduk['stok']}',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            if (_productController.filterProduct.isEmpty) const Spacer()
          ],
        ),
      );
    });
  }
}
