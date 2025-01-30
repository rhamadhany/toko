import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView extends StatelessWidget {
  const QRView({super.key, required this.produk});
  final RxMap<String, dynamic> produk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produk['produk']),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              // embeddedImage: Icon(icon),
              data: produk['key'],
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    produk['key'],
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
