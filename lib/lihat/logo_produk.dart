import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Card> logoProdukOnline(
    String gambar, int sisa, double size, double scale) async {
  if (gambar.startsWith('/data')) {
    return logoProduk(gambar, sisa, size, scale);
  } else if (gambar == '') {
    return noLogoProduk(size, sisa);
  } else if (gambar.startsWith('blob:')) {
    final response = await http.get(Uri.parse(gambar));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return cardGambar64(sisa, scale, bytes, size);
    } else {
      return noLogoProduk(size, sisa);
    }
  } else {
    final decode = base64Decode(gambar);

    return cardGambar64(sisa, scale, Uint8List.fromList(decode), size);
  }
}

Card cardGambar64(int sisa, double scale, Uint8List gambarDecode, double size) {
  return Card(
    shadowColor: Colors.black,
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue)),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Transform.scale(
          scale: scale,
          child: Image.memory(
            gambarDecode,
            width: size,
            height: size,
          ),
        ),
      ),
    ),
  );
}

Card logoProduk(dynamic gambar, int sisa, double size, double scale) {
  return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue)),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
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

Card noLogoProduk(double size, int sisa) {
  return Card(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue)),
    child: Center(
      child: Transform.scale(
        scale: 1.25,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Icon(
            Icons.image,
            size: size,
          ),
        ),
      ),
    ),
  );
}
