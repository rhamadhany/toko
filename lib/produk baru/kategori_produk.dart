import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/Models/icon_picker_icon.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
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
                                    return ListTile(leading: Icon(IconData(_productController.daftarKategori[index]['icon'], fontFamily: 'MaterialIcons')),
                                      onLongPress: () {
                                        if (removeIndex.value == '' ||
                                            removeIndex.value !=
                                                    _productController
                                                            .daftarKategori[
                                                        index]['kategori'] &&
                                                _productController
                                                            .daftarKategori[
                                                        index]['kategori'] !=
                                                    'Semua') {
                                          removeIndex.value = _productController
                                                  .daftarKategori[index]
                                              ['kategori'];
                                          // _productController
                                          //     .saveDaftarKategori();
                                        } else {
                                          removeIndex.value = '';
                                        }
                                      },
                                      onTap: () {
                                        _productController.kategoriAdd.value =
                                            _productController
                                                    .daftarKategori[index]
                                                ['kategori'];

                                        Get.back();
                                      },
                                      trailing: _productController
                                                      .daftarKategori[index]
                                                  ['kategori'] ==
                                              removeIndex.value
                                          ? IconButton(
                                              onPressed: () {
                                                _productController
                                                    .daftarKategori
                                                    .removeWhere((kategori) =>
                                                        kategori['kategori'] ==
                                                        removeIndex.value);
                                                removeIndex.value = '';
                                              },
                                              icon: const Icon(Icons.remove))
                                          : _productController
                                                      .kategoriAdd.value ==
                                                  _productController
                                                          .daftarKategori[index]
                                                      ['kategori']
                                              ? const Icon(Icons.circle)
                                              : null,
                                      title: Text(_productController
                                          .daftarKategori[index]['kategori']),
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
                          if (_productController.daftarKategori.any(
                              (kategori) => kategori['kategori'] == value)) {
                            Get.snackbar('Error', 'Kategori sudah ada',
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                                snackPosition: SnackPosition.BOTTOM);
                          } else {
                            _productController.daftarKategori.add({
                              'kategori': value,
                              'icon': _productController.iconsTerpilih.value,
                            });

                            _productController.saveDaftarKategori();
                            addController.clear();
                          }
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              IconData(_productController.iconsTerpilih.value,
                                  fontFamily: 'MaterialIcons'),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.emoji_emotions),
                              onPressed: () {
                                pickIcons();
                              },
                            ),
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

  final Rx<IconData> iconsTerpilih = Rx<IconData>(Icons.grid_view);

  pickIcons() async {
    final picker = await showIconPicker(
      Get.overlayContext!,
      configuration: SinglePickerConfiguration(
        iconPackModes: [IconPack.allMaterial],
      ),
    );

    _productController.iconsTerpilih.value =
        picker?.data.codePoint ?? Icons.grid_view.codePoint;
  }
}
