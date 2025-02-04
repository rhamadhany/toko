import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/penambahan/rincian_penambahan.dart';

class LaporanHarian extends StatelessWidget {
  LaporanHarian({super.key});
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  final headList = ['Tanggal', 'Terjual', 'Modal', 'Omset', 'Laba'];
  final jumlahHari = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dataPenambahan = iniasiasiData();

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
                  .map((h) => DataColumn(
                        label: Text(
                          h,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ))
                  .toList(),
              rows: List.generate(jumlahHari.value, (index) {
                final jumlah =
                    dataPenambahan.values.elementAt(index)['jumlah'] == 0
                        ? '-'
                        : dataPenambahan.values
                            .elementAt(index)['jumlah']
                            .toString();
                final modal = dataPenambahan.values.elementAt(index)['modal'] ==
                        0
                    ? '-'
                    : 'Rp ${_productController.regexNominal(dataPenambahan.values.elementAt(index)['modal'].toString())}';
                final omset = dataPenambahan.values.elementAt(index)['omset'] ==
                        0
                    ? '-'
                    : 'Rp ${_productController.regexNominal(dataPenambahan.values.elementAt(index)['omset'].toString())}';
                final laba = dataPenambahan.values.elementAt(index)['laba'] == 0
                    ? '-'
                    : 'Rp ${_productController.regexNominal(dataPenambahan.values.elementAt(index)['laba'].toString())}';
                return DataRow(
                    onSelectChanged: (_) {
                      final tanggalSelect =
                          dataPenambahan.keys.elementAt(index);

                      Get.to(() => RincianPenambahan(
                            tanggal: tanggalSelect.obs,
                          ));
                    },
                    cells: [
                      DataCell(Text(dataPenambahan.values
                          .elementAt(index)['tanggal']
                          .toString())),
                      DataCell(Center(child: Text(jumlah))),
                      DataCell(Text(modal)),
                      DataCell(Text(omset)),
                      DataCell(Text(laba)),
                    ]);
              }),
            ),
          ),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> iniasiasiData() {
    Map<String, Map<String, dynamic>> dataPenjualan = {};
    final penjualan = _laporanController.penjualan;
    final bulan = _laporanController.bulanTerpilih.value;
    final tahun = _laporanController.tahunTerpilih.value;
    final indexBulan =
        _laporanController.namaBulan.indexWhere((n) => n == bulan) + 1;
    jumlahHari.value = DateTime(tahun, indexBulan + 1, 0).day;
    for (int i = 1; i <= jumlahHari.value; i++) {
      final tanggal = DateTime(tahun, indexBulan, i);
      final formatTanggal = DateFormat('dd-MM-yyyy').format(tanggal);

      dataPenjualan[formatTanggal] = {
        'tanggal': formatTanggal,
        'jumlah': 0,
        'modal': 0,
        'omset': 0,
        'laba': 0,
      };
    }
    for (var item in penjualan) {
      final tanggal = item['tanggal'].split(' ')[0];
      final tahunParse = int.tryParse(tanggal.split('-')[0])!;
      final bulanParse = int.tryParse(tanggal.split('-')[1])!;
      final hariParse = int.tryParse(tanggal.split('-')[2])!;

      final date = DateTime(tahunParse, bulanParse, hariParse);
      final formatTanggal = DateFormat('dd-MM-yyyy').format(date);
      if (bulanParse != indexBulan || tahunParse != tahun) {
        continue;
      }
      int jumlah = item['jumlah'];
      // print(jumlah);
      int hargaBeli = int.tryParse(item['harga_beli'])!;
      int hargaJual = int.tryParse(item['harga_jual'])!;
      int modal = jumlah * hargaBeli;
      int omset = jumlah * hargaJual;
      int laba = omset - modal;
      final data = dataPenjualan[formatTanggal]!;
      data['jumlah'] += jumlah;
      data['modal'] += modal;
      data['omset'] += omset;
      data['laba'] += laba;
    }

    // print(dataPenambahan);
    return dataPenjualan;
  }
}
