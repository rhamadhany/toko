import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';

class PenambahanBulanan extends StatelessWidget {
  PenambahanBulanan({super.key});
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  final headList = ['Bulan', 'Jumlah', 'Modal', 'Omset', 'Laba'];
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dataPenambahan = initData();
      return SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              showCheckboxColumn: false,
              columnSpacing: 20,
              columns: headList
                  .map((head) => DataColumn(
                          label: Text(
                        head,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )))
                  .toList(),
              rows: dataPenambahan.entries
                  .map((data) => DataRow(
                      cells: headList
                          .map((head) => DataCell(head == 'Jumlah'
                              ? Center(
                                  child: Text(data.value[head].toString()),
                                )
                              : Text(head != 'Bulan'
                                  ? 'Rp ${_productController.regexNominal(data.value[head].toString())}'
                                  : data.value[head].toString())))
                          .toList()))
                  .toList()),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> initData() {
    Map<String, Map<String, dynamic>> dataPenambahan = {};
    final penambahan = _laporanController.penambahan;
    final tahun = _laporanController.tahunTerpilih.value;

    final daftarTahun = penambahan.where((data) {
      final tanggalProduk = int.tryParse(data['tanggal'].split('-')[0]);

      return tanggalProduk == tahun;
    }).toList();

    for (var bulan in _laporanController.namaBulan) {
      final formatBulan = '$bulan $tahun';
      dataPenambahan[formatBulan] = {
        'Bulan': formatBulan,
        'Jumlah': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };
    }
    for (var item in daftarTahun) {
      final parseTanggal = item['tanggal'];
      final splitTahun = int.tryParse(parseTanggal.split('-')[0]);
      final splitBulan = int.tryParse(parseTanggal.split('-')[1]);
      final bulan = _laporanController.namaBulan[splitBulan! - 1];

      final formatTanggal = '$bulan $splitTahun';
      final jumlah = item['stok'];
      final hargaBeli = int.tryParse(item['harga_beli']);
      final hargaJual = int.tryParse(item['harga_jual']);
      final modal = jumlah * hargaBeli;
      final omset = jumlah * hargaJual;
      final laba = omset - modal;

      final data = dataPenambahan[formatTanggal]!;
      data['Jumlah'] += jumlah;
      data['Modal'] += modal;
      data['Omset'] += omset;
      data['Laba'] += laba;
    }

    return dataPenambahan;
  }
}
