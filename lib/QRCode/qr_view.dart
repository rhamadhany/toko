import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView extends StatelessWidget {
  const QRView({super.key, required this.produk});
  final RxMap<String, dynamic> produk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          produk['produk'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              backgroundColor: Colors.white,
              // embeddedImage: Icon(icon),
              data: produk['key'],
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: produk['key']));
                  Get.snackbar(
                    'Berhasil',
                    'Kode QR berhasil disalin ke clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                child: const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Salin Kode', // Mengganti teks dengan "Salin Kode" agar lebih informatif
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
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
