import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';

class RincianHarian extends StatelessWidget {
  RincianHarian({super.key, required this.tanggal});
  final String tanggal;

  final headList = ['Produk', 'Jumlah', 'Modal', 'Omset', 'Laba'];

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
        if (hargaBeli != null && hargaJual != null && jumlah != null) {
          final modal = hargaBeli * jumlah;
          final omset = hargaJual * jumlah;
          final laba = omset - modal;

          final modalFormat = _productController.regexNominal(modal.toString());
          final omsetFormat = _productController.regexNominal(omset.toString());
          final labaFormat = _productController.regexNominal(laba.toString());
          rincianPenjualan.add({
            'id': item['id'].toString(),
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
            title: Text(
              tanggal,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
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
                  final laba = _productController.regexNominal(produk['laba']);
                  final modal =
                      _productController.regexNominal(produk['modal']);
                  return DataRow(cells: [
                    DataCell(Center(child: Text(produk['produk']))),
                    DataCell(Center(child: Text(produk['jumlah']))),
                    DataCell(Text(modal)),
                    DataCell(Text(omset)),
                    DataCell(Text(laba)),
                  ]);
                })),
          ));
    });
  }
}
