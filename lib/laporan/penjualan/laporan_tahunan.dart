import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/penjualan/laporan_bulanan.dart';

class LaporanTahunan extends StatelessWidget {
  LaporanTahunan({super.key});
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();

  final headList = ['Tahun', 'Terjual', 'Modal', 'Omset', 'Laba'];
  final daftarTahun = [].obs;
  final tahunTertinggi = 0.obs;
  final tahunTerendah = 0.obs;
  @override
  Widget build(BuildContext context) {
    inisiasiDaftarTahun();
    final penjualan = hitungLaporanTahunan();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 12,
          columns: List.generate(headList.length, (index) {
            return DataColumn(label: Text(headList[index]));
          }),
          rows: List.generate(daftarTahun.length, (index) {
            // print(penjualan);
            final tahunIndex = penjualan[daftarTahun[index]];

            final jumlah = convertString(tahunIndex, 'jumlah');
            final modal = convertString(tahunIndex, 'modal');
            final omset = convertString(tahunIndex, 'omset');
            final laba = convertString(tahunIndex, 'laba');
            return DataRow(
                onSelectChanged: (_) {
                  _laporanController.tahunTerpilih.value =
                      int.tryParse(daftarTahun[index]) ?? DateTime.now().year;
                  _laporanController.viewMode.value = 'Bulan';
                  LaporanBulanan.dariTahun.value = true;
                },
                cells: [
                  DataCell(Text(daftarTahun[index])),
                  DataCell(Text(jumlah)),
                  DataCell(Text(modal)),
                  DataCell(Text(omset)),
                  DataCell(Text(laba)),
                ]);
          })),
    );
  }

  inisiasiDaftarTahun() {
    final penjualan = _laporanController.penjualan;
    daftarTahun.value = penjualan
        .map((produk) => produk['tanggal'].split('-')[0])
        .toSet()
        .toList();
    if (daftarTahun.isEmpty) {
      daftarTahun.value = [DateTime.now().year];
    }
    daftarTahun.sort((a, b) => a.compareTo(b));
    tahunTerendah.value = int.tryParse(daftarTahun.first)!;
    tahunTertinggi.value = int.tryParse(daftarTahun.last)!;
  }

  hitungLaporanTahunan() {
    final penjualan = _laporanController.penjualan;
    Map<String, Map<String, dynamic>> daftarPenjualan = {};
    for (var item in penjualan) {
      final tahun = item['tanggal'].split('-')[0];
      // print(tahun);
      if (!daftarPenjualan.containsKey(tahun)) {
        daftarPenjualan[tahun] = {
          'jumlah': 0,
          'modal': 0,
          'omset': 0,
          'laba': 0,
        };
      }

      final jumlah = item['jumlah'];
      final hargaBeli = int.tryParse(item['harga_beli']) ?? 0;
      final hargaJual = int.tryParse(item['harga_jual']) ?? 0;
      final modal = hargaBeli * jumlah;
      final omset = hargaJual * jumlah;
      final laba = omset - modal;

      final dataInput = daftarPenjualan[tahun]!;
      dataInput['jumlah'] += jumlah;
      dataInput['omset'] += omset;
      dataInput['modal'] += modal;
      dataInput['laba'] += laba;
      daftarPenjualan[tahun] = dataInput;
    }

    return daftarPenjualan;
  }

  String convertString(dynamic tahunIndex, String kategori) {
    return tahunIndex == null ||
            tahunIndex[kategori] == null ||
            tahunIndex[kategori] == 0
        ? '-'
        : kategori == 'jumlah'
            ? tahunIndex[kategori].toString()
            : 'Rp ${_productController.regexNominal(tahunIndex[kategori].toString())}';
  }
}
