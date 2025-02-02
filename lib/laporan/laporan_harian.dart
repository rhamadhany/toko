import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/laporan_penjualan.dart';
import 'package:myapp/laporan/rincian_harian.dart';

class LaporanHarian extends StatelessWidget {
  LaporanHarian({super.key});
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  // final int indexBulan;
  static final dariBulan = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final penjualanHarian = hitungPenjualanHarian();
      final tahunSekarang = DateTime.now().year;

      final bulanTerpilih = _laporanController.bulanTerpilih.split(' ')[0];
      final indexBulan = _laporanController.namaBulan
              .indexWhere((item) => item == bulanTerpilih) +
          1;
      // final jumlahHari = DateTime(tahunSekarang, indexBulan + 1, 0).day;
      final jumlahHari = DateTime(tahunSekarang, indexBulan + 1, 0).day;
      return PopScope(
        canPop: dariBulan.value,
        onPopInvokedWithResult: (didpop, _) {
          _laporanController.viewMode.value = 'Bulan';
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 12,
            columns: LaporanPenjualan.headList
                .map((e) => DataColumn(label: Text(e)))
                .toList(),
            rows: List.generate(
              jumlahHari,
              (index) {
                final tanggal = DateTime(tahunSekarang, indexBulan, index + 1);
                final tanggalFormat = DateFormat('dd-MM-yyyy').format(tanggal);
                final dataPenjualan = penjualanHarian[tanggalFormat] ??
                    {'terjual': '-', 'modal': '-', 'omset': '-', 'laba': '-'};
                // print(dataPenjualan);
                final terjual = dataPenjualan['terjual'] == 0
                    ? '-'
                    : dataPenjualan['terjual'].toString();
                final modal =
                    dataPenjualan['modal'] == 0 ? '-' : dataPenjualan['modal'];
                final omset =
                    dataPenjualan['omset'] == 0 ? '-' : dataPenjualan['omset'];
                final laba =
                    dataPenjualan['laba'] == 0 ? '-' : dataPenjualan['laba'];
                return DataRow(
                  onSelectChanged: (value) {
                    Get.to(() => RincianHarian(tanggal: tanggalFormat));
                  },
                  cells: [
                    DataCell(Text(tanggalFormat)),
                    DataCell(Text(terjual)),
                    DataCell(Text(formatRupiah(modal))),
                    DataCell(Text(formatRupiah(omset))),
                    DataCell(Text(formatRupiah(laba))),
                  ],
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> hitungPenjualanHarian() {
    Map<String, Map<String, dynamic>> penjualanHarian = {};
    // final tahunSekarang = DateTime.now().year;

    final bulanTerpilih = _laporanController.bulanTerpilih.value;
    final tahunTerpilih = _laporanController.tahunTerpilih.value;
    final indexBulan = _laporanController.namaBulan
            .indexWhere((item) => item == bulanTerpilih) +
        1;
    // final jumlahHari = DateTime(tahunSekarang, indexBulan + 1, 0).day;
    final jumlahHari = DateTime(tahunTerpilih, indexBulan + 1, 0).day;
    print('indexBulan: $indexBulan');

    for (var i = 1; i <= jumlahHari; i++) {
      final tanggal = DateTime(tahunTerpilih, indexBulan, i);
      final tanggalFormat = DateFormat('dd-MM-yyyy').format(tanggal);
      penjualanHarian[tanggalFormat] = {
        'terjual': 0,
        'modal': 0,
        'omset': 0,
        'laba': 0,
      };
    }
    for (var item in _laporanController.penjualan) {
      final parseTanggal = DateFormat('yyyy-MM-dd').parse(item['tanggal']);
      if (parseTanggal.month != indexBulan ||
          parseTanggal.year != tahunTerpilih) {
        continue;
      }

      final jumlah = _parseToInt(item['jumlah']) ?? 0;
      final hargabeli = _parseToInt(item['harga_beli']) ?? 0;
      final hargaJual = _parseToInt(item['harga_jual']) ?? 0;

      final modal = hargabeli * jumlah;
      final omset = hargaJual * jumlah;
      final laba = omset - modal;

      final tanggalFormat = DateFormat('dd-MM-yyyy').format(parseTanggal);
      final dataPenjualan = penjualanHarian[tanggalFormat]!;

      dataPenjualan['terjual'] += jumlah == 0 ? '-' : jumlah;
      dataPenjualan['modal'] += modal == 0 ? '-' : modal;
      dataPenjualan['omset'] += omset == 0 ? '-' : omset;
      dataPenjualan['laba'] += laba == 0 ? '-' : laba;

      penjualanHarian[tanggalFormat] = dataPenjualan;
    }
    return penjualanHarian;
  }

  int? _parseToInt(dynamic value) {
    try {
      return int.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  String formatRupiah(dynamic data) {
    return data is int || data is double
        ? 'Rp ${_productController.regexNominal(data.toString())}'
        : '-';
  }
}
