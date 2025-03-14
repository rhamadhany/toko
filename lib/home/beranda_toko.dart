import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/QRCode/qr_scanner.dart';
import 'package:myapp/controller/main_controller.dart';

import 'package:myapp/lihat/lihat_produk.dart';
import 'package:myapp/lihat/logo_produk.dart';
import 'package:myapp/controller/product_controller.dart';

class HomeToko extends GetView<ProductController> {
  HomeToko({
    super.key,
    required this.isManager,
  });

  final bool isManager;

  // final ProductController _productController = Get.find();
  final MainController _mainController = Get.find();
  static final focusPencarian = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            if (controller.showSearch.value)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
                child: TextField(
                  autofocus: true,
                  controller: controller.pencarianController,
                  focusNode: focusPencarian,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () async {
                          focusPencarian.unfocus();
                          await Future.delayed(const Duration(seconds: 1));
                          Get.to(() => QRScanner(
                                isManager: isManager,
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
                    controller.searchText.value = value;
                  },
                ),
              ),
            KategoriToko(),
            // _productController.daftarKategori.map((kategori){
            //   return Row()
            // })
            if (controller.allProduct.isNotEmpty &&
                controller.daftarKategori.length > 1)
              IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  if (controller.filterProduct.isEmpty) const Spacer(),
                  controller.filterProduct.isEmpty
                      ? Center(
                          child: Icon(
                          Icons.shop,
                          size: Get.height * 0.3,
                        ))
                      : Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: kIsWeb ? 4 : 2,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: controller.filterProduct.length,
                            itemBuilder: (context, indexProduct) {
                              final listProduk =
                                  controller.filterProduct[indexProduct].obs;

                              final terjual = listProduk['terjual'];
                              final stok = listProduk['stok'];
                              final sisa = stok - terjual;
                              return InkWell(
                                onTap: () {
                                  if (controller.showCheckBoxRemove.value) {
                                    bool isChecked = controller
                                                .mapCheckBoxRemove[indexProduct]
                                            ['isSelected'] ==
                                        'true';
                                    isChecked = !isChecked;

                                    controller.mapCheckBoxRemove[indexProduct]
                                            ['isSelected'] =
                                        isChecked
                                            ? true.toString()
                                            : false.toString();

                                    controller.mapCheckBoxRemove.refresh();
                                  } else {
                                    Get.to(() => LihatProduk(
                                          produk: listProduk,
                                          isManager: isManager,
                                        ));
                                  }
                                },
                                onLongPress: () async {
                                  if (isManager) {
                                    controller.showCheckBoxRemove.value =
                                        !controller.showCheckBoxRemove.value;
                                    if (controller.showCheckBoxRemove.value) {
                                      await controller.generateMapCheckBox();
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            if (listProduk['gambar'].isNotEmpty)
                                              // logoProduk(
                                              //     listProduk['gambar'][0],
                                              //     sisa,
                                              //     200,
                                              //     2.5),
                                              FutureBuilder(
                                                  future: logoProdukOnline(
                                                      listProduk['gambar'][0],
                                                      sisa,
                                                      200,
                                                      2.5),
                                                  builder:
                                                      (context, snapshots) {
                                                    if (snapshots.hasData &&
                                                        snapshots.data !=
                                                            null) {
                                                      return snapshots.data!;
                                                    } else {
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.blue,
                                                        ),
                                                      );
                                                    }
                                                  }),
                                            if (listProduk['gambar'].isEmpty)
                                              noLogoProduk(170, sisa),
                                            if (controller
                                                    .showCheckBoxRemove.value &&
                                                _mainController
                                                        .tabIndex.value ==
                                                    1)
                                              Obx(() {
                                                final isChecked = RxBool(
                                                    controller.mapCheckBoxRemove[
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
                                                        controller.mapCheckBoxRemove[
                                                                    indexProduct]
                                                                ['isSelected'] =
                                                            value.toString();

                                                        controller
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
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            Text(
                                              "Rp ${controller.hargaProduk(listProduk)}",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Terjual ${listProduk['terjual']}/${listProduk['stok']}',
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                  if (controller.filterProduct.isEmpty) const Spacer()
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class KategoriToko extends GetView<ProductController> {
  const KategoriToko({super.key});
  @override
  Widget build(BuildContext context) {
    return
        // return Container();
        //  return   ..._productController.daftarKategori
        // .map((kategori) =>
        Padding(
      padding: const EdgeInsets.all(4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...controller.daftarKategori.map((kategori) {
              return Card(
                color: kategori['kategori'] == controller.kategoriAktif.value
                    ? Colors.blue
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      controller.kategoriAktif.value = kategori['kategori'];
                    },
                    child: Row(
                      children: [
                        Icon(
                          IconData(kategori['icon'],
                              fontFamily: 'MaterialIcons'),
                          color: kategori['kategori'] ==
                                  controller.kategoriAktif.value
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
                                      controller.kategoriAktif.value
                                  ? Colors.white
                                  : null),
                        ),
                      ],
                    ),
                  ),
                )),
              );
            })
          ],
        ),
      ),
    );
  }
}
