import 'package:flutter/material.dart';
import 'package:myapp/lihat/logo_produk.dart';

class FutureLogoOnline extends StatelessWidget {
  const FutureLogoOnline({
    super.key,
    required this.gambar,
    required this.size,
    required this.childOnly,
  });
  final double size;
  final String gambar;
  final bool childOnly;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: logoProdukOnline(gambar, 10, size, 2.5),
        builder: (context, snapshots) {
          if (snapshots.hasData && snapshots.data != null) {
            return childOnly ? snapshots.data!.child! : snapshots.data!;
          } else {
            return Stack(
              alignment: Alignment.center,
              children: [
                noLogoProduk(size, 10),
                CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ],
            );
          }
        });
  }
}
