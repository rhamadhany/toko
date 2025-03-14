import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';

class KategoriToko extends GetView<ProductController> {
  const KategoriToko({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
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
