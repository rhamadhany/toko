import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:http/http.dart' as http;

class GambarPenuh extends StatelessWidget {
  const GambarPenuh({super.key, required this.gambar});
  final String gambar;

  Future<Uint8List?> fetchGambar() async {
    if (gambar.startsWith('/data')) {
      return await File(gambar).readAsBytes();
    } else {
      final url = Uri.parse('$domain/produk/load_gambar.php');
      final response = await http.post(url, body: {'gambar': gambar});

      if (response.statusCode == 200) {
        final base64 = jsonDecode(response.body);
        final gambarDecode = base64Decode(base64);
        return gambarDecode;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:

            // FutureBuilder(
            //     future: fetchGambar(),
            //     builder: (context, status) {
            //       if (status.hasData && status.data != null) {
            //         return InteractiveViewer(
            //           clipBehavior: Clip.none,
            //           minScale: 1,
            //           maxScale: 5,
            //           child: SizedBox(
            //             height: Get.height,
            //             width: Get.width,
            //             child: Center(
            //               child:
            //                   Image.memory(base64Decode(gambar), fit: BoxFit.contain,
            //                       errorBuilder: (context, error, stackTrace) {
            //                 return const Center(
            //                     child: Text('Gambar tidak ditemukan'));
            //               }),
            //             ),
            //           ),
            //         );
            //       } else {
            //         return Center(
            //           child: CircularProgressIndicator(
            //             color: Colors.blue,
            //           ),
            //         );
            //       }
            //     }),

            InteractiveViewer(
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
