import 'dart:io';

import 'package:flutter/material.dart';

Card logoProduk(dynamic gambar, int sisa, double size, double scale) {
  return Card(
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: sisa <= 0 ? Colors.red : Colors.transparent,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Transform.scale(
          scale: scale,
          child: Image.file(
            File(gambar),
            width: size,
            height: size,
          ),
        ),
      ),
    ),
  );
}

Center noLogoProduk(double size, int sisa) {
  return Center(
    child: Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: sisa <= 0 ? Colors.red : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Transform.scale(
        scale: 1.25,
        child: Icon(
          Icons.image,
          size: size,
        ),
      ),
    ),
  );
}
