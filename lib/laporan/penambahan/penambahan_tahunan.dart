import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/penjualan/laporan_penjualan.dart';

class PenambahanTahunan extends StatelessWidget {
  PenambahanTahunan({super.key});
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  final headList = ['Tahun', 'Jumlah', 'Modal', 'Omset', 'Laba'];
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dataPenjualan = initData();

      return Container(
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
                    .map((e) => DataColumn(
                            label: Text(
                          e,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        )))
                    .toList(),
                rows: dataPenjualan.entries
                    .map((data) => DataRow(
                        onSelectChanged: (_) {
                          _laporanController.tahunTerpilih.value =
                              int.tryParse(data.key)!;
                          _laporanController.viewMode.value = 'Bulan';
                          LaporanPenjualan.dariTahun.value = true;
                        },
                        cells: headList
                            .map((head) => DataCell(head == 'Jumlah'
                                ? Center(
                                    child: Text(data.value[head].toString()))
                                : Text(head != 'Tahun'
                                    ? 'Rp ${_productController.regexNominal(data.value[head].toString())}'
                                    : data.value[head].toString())))
                            .toList()))
                    .toList()),
          ),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> initData() {
    final dataPenambahan = <String, Map<String, dynamic>>{};
    final penambahan = _laporanController.penambahan;
    final daftar =
        penambahan.map((d) => d['tanggal'].split('-')[0]).toSet().toList();

    for (var item in daftar) {
      final tahun = penambahan
          .where((d) => item == d['tanggal'].split('-')[0])
          .toSet()
          .toList();

      dataPenambahan[item] = {
        'Tahun': item,
        'Jumlah': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };

      for (var data in tahun) {
        final jumlah = data['stok'];
        final hargaBeli = int.tryParse(data['harga_beli']);
        final hargaJual = int.tryParse(data['harga_jual']);
        final modal = jumlah * hargaBeli;
        final omset = jumlah * hargaJual;
        final laba = omset - modal;
        final update = dataPenambahan[item]!;
        update['Jumlah'] += jumlah;
        update['Modal'] += modal;
        update['Omset'] += omset;
        update['Laba'] += laba;
      }
    }

    return dataPenambahan;
  }
}
