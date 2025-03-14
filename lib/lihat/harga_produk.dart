import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';

class HargaProduk extends GetView<ProductController> {
  const HargaProduk({super.key, required this.produk});

  final RxMap<String, dynamic> produk;
  @override
  Widget build(BuildContext context) {
    // return Container();
    // Widget hargaProduk() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
          child: Text(
            "Rp ${controller.hargaProduk(produk)}",
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    // }
  }
}
