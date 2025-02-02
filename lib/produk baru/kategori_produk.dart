import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';

class KategoriProduk extends StatelessWidget {
  KategoriProduk({super.key});
  final ProductController _productController = Get.find();
  final showAdd = false.obs;
  final addController = TextEditingController();
  final removeIndex = ''.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Dialog(
        child: SizedBox(
          height: Get.height * 0.8,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 24),
                    child: Row(
                      children: [
                        const Text(
                          'Kategori',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const Spacer(),
                        IconButton(
                            iconSize: 30,
                            onPressed: () {
                              showAdd.value = !showAdd.value;
                            },
                            icon: const Icon(Icons.add))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListView.builder(
                          itemCount: _productController.daftarKategori.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Obx(() {
                                    return ListTile(
                                      onLongPress: () {
                                        if (removeIndex.value == '' ||
                                            removeIndex.value !=
                                                    _productController
                                                            .daftarKategori[
                                                        index] &&
                                                _productController
                                                            .daftarKategori[
                                                        index] !=
                                                    'Semua') {
                                          removeIndex.value = _productController
                                              .daftarKategori[index];
                                          _productController
                                              .saveDaftarKategori();
                                        } else {
                                          removeIndex.value = '';
                                        }
                                        // print(item)
                                      },
                                      onTap: () {
                                        _productController.kategoriAdd.value =
                                            _productController
                                                .daftarKategori[index];
                                        Get.back();
                                      },
                                      trailing: _productController
                                                  .daftarKategori[index] ==
                                              removeIndex.value
                                          ? IconButton(
                                              onPressed: () {
                                                _productController
                                                    .daftarKategori
                                                    .remove(removeIndex.value);
                                                removeIndex.value = '';
                                              },
                                              icon: const Icon(Icons.remove))
                                          : _productController
                                                      .kategoriAdd.value ==
                                                  _productController
                                                      .daftarKategori[index]
                                              ? const Icon(Icons.circle)
                                              : null,
                                      title: Text(_productController
                                          .daftarKategori[index]),
                                    );
                                  })),
                            );
                          }),
                    ),
                  ),
                  if (showAdd.value)
                    SizedBox(
                      height: Get.height * 0.1,
                    )
                ],
              ),
              if (showAdd.value)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: TextField(
                        controller: addController,
                        onSubmitted: (value) {
                          if (_productController.daftarKategori
                              .any((kategori) => kategori == value)) {
                            Get.snackbar('Error', 'Kategori sudah ada',
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                                snackPosition: SnackPosition.BOTTOM);
                          } else {
                            _productController.daftarKategori.add(value);
                            _productController.saveDaftarKategori();
                            addController.clear();
                          }
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Nama Kategori'),
                            hintText: 'Nama Kategori'),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      );
    });
  }
}
