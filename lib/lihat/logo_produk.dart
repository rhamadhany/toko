import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/controller/splash_controller.dart';

Future<Card> logoProdukOnline(
    String gambar, int sisa, double size, double scale) async {
  if (gambar.startsWith('/data')) {
    return logoProduk(gambar, sisa, size, scale);
  } else if (gambar == '') {
    return noLogoProduk(size, sisa);
  } else {
    Uri? url;
    http.Response? response;
    if (gambar.startsWith('blob')) {
      url = Uri.parse(gambar);
      response = await http.get(url);
    } else {
      url = Uri.parse('$domain/produk/load_gambar.php');
      response = await http.post(url, body: {'gambar': gambar});
    }

    if (response.statusCode == 200) {
      Uint8List gambarDecode;

      if (gambar.startsWith('blob')) {
        gambarDecode = response.bodyBytes;
      } else {
        final base64 = jsonDecode(response.body);
        gambarDecode = base64Decode(base64);
      }

      return cardGambar64(sisa, scale, gambarDecode, size);
    } else {
      return noLogoProduk(size, sisa).child as Card;
    }
  }
}

Card cardGambar64(int sisa, double scale, Uint8List gambarDecode, double size) {
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
