import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GambarPenuh extends StatelessWidget {
  const GambarPenuh({super.key, required this.gambar});
  final String gambar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: InteractiveViewer(
      clipBehavior: Clip.none,
      minScale: 1,
      maxScale: 5,
      child: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Center(
          child: Image.memory(base64Decode(gambar), fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Gambar tidak ditemukan'));
          }),
        ),
      ),
    ));
  }
}
