import 'dart:io';

import 'package:flutter/material.dart';

Card logoProduk(dynamic gambar, double size, double scale) {
  return Card(
    // color: Colors.blue,
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

Center noLogoProduk(double size) {
  return Center(
    child: Card(
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
