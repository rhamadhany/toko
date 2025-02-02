import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/penjualan/laporan_harian.dart';
import 'package:myapp/pengaturan/biometrik.dart';

class LaporanBulanan extends StatelessWidget {
  LaporanBulanan({super.key});
  final headList = ['Bulan', 'Terjual', 'Modal', 'Omset', 'Laba'];
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final penjualan = RxMap<String, Map<String, dynamic>>().obs;
  static final dariTahun = false.obs;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_biometrikController.tabIndex.value == 2) {
        penjualan.value = hitungBulanan();
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 20,
            columns: List.generate(headList.length, (index) {
              return DataColumn(
                label: Center(
                  child: Text(
                    headList[index],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            }),
            rows: List.generate(_laporanController.namaBulan.length, (index) {
              final tahunTerpilih = _laporanController.tahunTerpilih.value;
              final penjualanBulan = penjualan.value[
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

              return DataRow(
                  onSelectChanged: (_) {
                    LaporanHarian.dariBulan.value = true;
                    _laporanController.bulanTerpilih.value =
                        _laporanController.namaBulan[index];
                    _laporanController.viewMode.value = 'Hari';
                  },
                  cells: [
                    DataCell(Text(
                        '${_laporanController.namaBulan[index]} ${_laporanController.tahunTerpilih}')),
                    DataCell(Center(child: Text(terjual))),
                    DataCell(Text(modal)),
                    DataCell(Text(omset)),
                    DataCell(Text(laba)),
                  ]);
            })),
      );
    });
  }

  RxMap<String, Map<String, dynamic>> hitungBulanan() {
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

      final dataPenjualanBulanan = daftarPenjualan[tanggalFormat]!;
      dataPenjualanBulanan['terjual'] += terjual;
      dataPenjualanBulanan['modal'] += modal;
      dataPenjualanBulanan['omset'] += omset;
      dataPenjualanBulanan['laba'] += laba;
      daftarPenjualan[tanggalFormat] = dataPenjualanBulanan;
    }

    return daftarPenjualan.obs;
  }
}
