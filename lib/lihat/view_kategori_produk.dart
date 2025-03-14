import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';

class ViewKategoriProduk extends GetView<ProductController> {
  const ViewKategoriProduk({required this.produk, super.key});
  final RxMap<String, dynamic> produk;
  @override
  Widget build(BuildContext context) {
    // return Container();
    final indexIcons = controller.daftarKategori
        .indexWhere((ind) => ind['kategori'] == produk['kategori']);

    return Container(
      decoration: BoxDecoration(
          color: Colors.purple, borderRadius: BorderRadius.circular(5)),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconData(controller.daftarKategori[indexIcons]['icon'],
                    fontFamily: 'MaterialIcons'),
                color: Colors.white,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  produk['kategori'].length > 12
                      ? produk['kategori'].substring(0, 12) + '...'
                      : produk['kategori'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  // Widget kategoriView() {
   
  // }