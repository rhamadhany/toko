import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/lihat/lihat_produk.dart';

class RincianHarian extends StatelessWidget {
  RincianHarian({super.key, required this.tanggal});
  final String tanggal;

  final headList = ['Tanggal', 'Produk', 'Jumlah', 'Modal', 'Omset', 'Laba'];

  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final revertTanggal =
          DateTime.parse(DateFormat('dd-MM-yyyy').parse(tanggal).toString());
      final formattedDate = DateFormat('yyyy-MM-dd').format(revertTanggal);
      final tanggalProduk = _laporanController.penjualan
          .where((produk) => produk['tanggal'].contains(formattedDate))
          .toList();

      List<Map<String, dynamic>> rincianPenjualan = [];

      for (var item in tanggalProduk) {
        final jumlah = item['jumlah'];
        final hargaBeli = int.tryParse(item['harga_beli']);
        final hargaJual = int.tryParse(item['harga_jual']);
        final tanggal = item['tanggal'];
        if (hargaBeli != null && hargaJual != null && jumlah != null) {
          final modal = hargaBeli * jumlah;
          final omset = hargaJual * jumlah;
          final laba = omset - modal;

          final modalFormat = _productController.regexNominal(modal.toString());
          final omsetFormat = _productController.regexNominal(omset.toString());
          final labaFormat = _productController.regexNominal(laba.toString());
          rincianPenjualan.add({
            'tanggal': tanggal,
            'key': item['key'].toString(),
            'produk': item['produk'].toString(),
            'jumlah': jumlah.toString(),
            'modal': 'Rp $modalFormat',
            'omset': 'Rp $omsetFormat',
            'laba': 'Rp $labaFormat'
          });
        }
      }
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            title: Text(
              tanggal,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.blue),
              borderRadius: BorderRadius.circular(0),
            ),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    showCheckboxColumn: false,
                    columnSpacing: 20,
                    columns: headList
                        .map((head) => DataColumn(
                                label: Center(
                                    child: Text(
                              head,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ))))
                        .toList(),
                    rows: List.generate(rincianPenjualan.length, (index) {
                      final produk = rincianPenjualan[index];

                      final omset =
                          _productController.regexNominal(produk['omset']);
                      final laba =
                          _productController.regexNominal(produk['laba']);
                      final modal =
                          _productController.regexNominal(produk['modal']);
                      return DataRow(
                          onSelectChanged: (_) {
                            final indexKey = _productController.allProduct
                                .indexWhere(
                                    (all) => all['key'] == produk['key']);

                            // print(indexKey.toString() +
                            // rincianPenjualan.toString());
                            if (indexKey != -1) {
                              Get.to(() => LihatProduk(
                                  produk: _productController
                                      .allProduct[indexKey].obs));
                            }
                          },
                          cells: [
                            DataCell(Text(produk['tanggal'])),
                            DataCell(Text(produk['produk'])),
                            DataCell(Center(child: Text(produk['jumlah']))),
                            DataCell(Text(modal)),
                            DataCell(Text(omset)),
                            DataCell(Text(laba)),
                          ]);
                    })),
              ),
            ),
          ));
    });
  }
}
