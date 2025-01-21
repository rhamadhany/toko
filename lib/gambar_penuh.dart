import 'dart:io';
import 'package:flutter/material.dart';

class GambarPenuh extends StatelessWidget {
  const GambarPenuh({super.key, required this.gambar});
  final String gambar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(gambar.split('/').last),
      // ),
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          maxScale: 5,
          minScale: 1,
          child: Image.file(File(gambar), fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Gambar tidak ditemukan'));
          }),
        ),
      ),
    );
  }
}
