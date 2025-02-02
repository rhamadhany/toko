import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/laporan_harian.dart';

class LaporanBulanan extends StatelessWidget {
  LaporanBulanan({super.key});
  final headList = ['Bulan', 'Terjual', 'Modal', 'Omset', 'Laba'];
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final penjualan = hitungBulanan();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 12,
            columns: List.generate(headList.length, (index) {
              return DataColumn(
                label: Text(headList[index]),
              );
            }),
            rows: List.generate(_laporanController.namaBulan.length, (index) {
              // print(penjualan);
              final tahunTerpilih = _laporanController.tahunTerpilih.value;
              final penjualanBulan = penjualan[
                  '${(index + 1).toString().padLeft(2, '0')}-$tahunTerpilih'];
              final terjual =
                  penjualanBulan != null && penjualanBulan['terjual'] != null
                      ? penjualanBulan['terjual'].toString()
                      : '-';
              final modal = penjualanBulan != null &&
                      penjualanBulan['modal'] != null
                  ? 'Rp ${_productController.regexNominal(penjualanBulan['modal'].toString())}'
                  : '-';
              final omset = penjualanBulan != null &&
                      penjualanBulan['omset'] != null
                  ? 'Rp ${_productController.regexNominal(penjualanBulan['omset'].toString())}'
                  : '-';
              final laba = penjualanBulan != null &&
                      penjualanBulan['laba'] != null
                  ? 'Rp ${_productController.regexNominal(penjualanBulan['laba'].toString())}'
                  : '-';
              // print(terjual);
              return DataRow(
                  onSelectChanged: (_) {
                    // print(index);
                    // print(_laporanController.namaBulan[index]);
                    // print(_laporanController.bulanTerpilih);
                    _laporanController.bulanTerpilih.value =
                        _laporanController.namaBulan[index];
                    _laporanController.viewMode.value = 'Hari';
                    // Get.to(() => LaporanHarian(
                    //     // indexBulan: index,
                    //     ));
                    // _laporanController.viewMode.value = 'hari';
                  },
                  cells: [
                    DataCell(Text(
                        '${_laporanController.namaBulan[index]} ${_laporanController.tahunTerpilih}')),
                    DataCell(Text(terjual)),
                    DataCell(Text(modal)),
                    DataCell(Text(omset)),
                    DataCell(Text(laba)),
                  ]);
            })),
      );
    });
  }

  hitungBulanan() {
    Map<String, Map<String, dynamic>> daftarPenjualan = {};
    final penjualan = _laporanController.penjualan;
    final tahunTerpilih = _laporanController.tahunTerpilih.value;

    for (var item in penjualan) {
      final parseTanggal = DateFormat('yyyy-MM-dd').parse(item['tanggal']);
      if (parseTanggal.year != tahunTerpilih) continue;
      final tanggalFormat = DateFormat('MM-yyyy').format(parseTanggal);
      if (!daftarPenjualan.containsKey(tanggalFormat)) {
        daftarPenjualan[tanggalFormat] = {
          'terjual': 0,
          'modal': 0,
          'omset': 0,
          'laba': 0
        };
      }

      final terjual = item['jumlah'];
      final hargaBeli = int.tryParse(item['harga_beli']);
      final hargaJual = int.tryParse(item['harga_jual']);
      final modal = terjual * hargaBeli;
      final omset = terjual * hargaJual;
      final laba = omset - modal;

      // print('terjual' + item['jumlah'].toString());

      final dataPenjualanBulanan = daftarPenjualan[tanggalFormat]!;
      dataPenjualanBulanan['terjual'] += terjual;
      dataPenjualanBulanan['modal'] += modal;
      dataPenjualanBulanan['omset'] += omset;
      dataPenjualanBulanan['laba'] += laba;
      daftarPenjualan[tanggalFormat] = dataPenjualanBulanan;
    }
    // print(daftarPenjualan);
    return daftarPenjualan;
  }
}
