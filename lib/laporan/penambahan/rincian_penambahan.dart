import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';

class RincianPenambahan extends StatelessWidget {
  RincianPenambahan({super.key, required this.tanggal});
  final RxString tanggal;
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  final headList = [
    'Tanggal',
    'Id',
    'Produk',
    'Jumlah',
    'Modal',
    'Omset',
    'Laba'
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dataPenambahan = initData();
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Text(
            tanggal.value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 20,
              columns: headList
                  .map((h) => DataColumn(
                      label: Text(h,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16))))
                  .toList(),
              rows: dataPenambahan.map((data) {
                return DataRow(
                    cells: headList.map((head) {
                  return DataCell(head == 'Jumlah'
                      ? Center(child: Text(data[head].toString()))
                      : Text(data[head].toString()));
                }).toList());
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  List<Map<String, dynamic>> initData() {
    List<Map<String, dynamic>> dataPenambahan = [];
    final produk = _laporanController.penambahan;

    final splitTanggal = int.tryParse(tanggal.value.split('-')[0])!;
    final splitBulan = int.tryParse(tanggal.value.split('-')[1])!;
    final splitTahun = int.tryParse(tanggal.value.split('-')[2])!;
    final date =
        DateTime(splitTahun, splitBulan, splitTanggal).toString().split(' ')[0];

    final tanggalProduk =
        produk.where((p) => p['tanggal'].split(' ')[0] == date).toList();

    for (var item in tanggalProduk) {
      final itemTanggal = item['tanggal'].split('.')[0];
      final produk = item['produk'];
      final key = item['key'];
      final jumlah = item['stok'];
      final hargaBeli = int.tryParse(item['harga_beli'])!;
      final hargaJual = int.tryParse(item['harga_jual'])!;
      int modal = jumlah * hargaBeli;
      int omset = jumlah * hargaJual;
      int laba = omset - modal;

      dataPenambahan.add({
        'Tanggal': itemTanggal,
        'Id': key,
        'Produk': produk,
        'Jumlah': jumlah,
        'Modal': 'Rp ${_productController.regexNominal(modal.toString())}',
        'Omset': 'Rp ${_productController.regexNominal(omset.toString())}',
        'Laba': 'Rp ${_productController.regexNominal(laba.toString())}',
      });
    }
    return dataPenambahan;
  }
}
