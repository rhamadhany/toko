import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/laporan_penjualan.dart';
import 'package:myapp/lihat/lihat_produk.dart';

class PenjualanData extends StatelessWidget {
  PenjualanData({
    super.key,
  });
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headList = _laporanController.viewMode.value == 'Rincian'
          ? ['Tanggal', 'Id', 'Produk', 'Terjual', 'Modal', 'Omset', 'Laba']
          : _laporanController.viewMode.value == 'Hari'
              ? ['Tanggal', 'Terjual', 'Modal', 'Omset', 'Laba']
              : _laporanController.viewMode.value == 'Bulan'
                  ? ['Bulan', 'Terjual', 'Modal', 'Omset', 'Laba']
                  : ['Tahun', 'Terjual', 'Modal', 'Omset', 'Laba'];

      final dataPenjualan = _laporanController.viewMode.value == 'Rincian'
          ? initRincianData()
          : _laporanController.viewMode.value == 'Hari'
              ? iniasiasiDataHarian()
              : _laporanController.viewMode.value == 'Bulan'
                  ? initDataBulanan()
                  : initDataTahunan();
      return Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.blue),
          borderRadius: BorderRadius.circular(0),
        ),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                DataTable(
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
                    rows: dataPenjualan.entries
                        .map((data) => DataRow(
                            onSelectChanged: (_) {
                              if (_laporanController.viewMode.value ==
                                  'Tahun') {
                                _laporanController.tahunTerpilih.value =
                                    int.tryParse(data.key)!;
                                _laporanController.viewMode.value = 'Bulan';
                                LaporanPenjualan.dariTahun.value = true;
                              } else if (_laporanController.viewMode.value ==
                                  'Bulan') {
                                LaporanPenjualan.dariBulan.value = true;

                                _laporanController.bulanTerpilih.value =
                                    data.key.split(' ')[0];
                                _laporanController.viewMode.value = 'Hari';
                              } else if (_laporanController.viewMode.value ==
                                  'Hari') {
                                _productController.tanggalHarian.value =
                                    data.key;
                                LaporanPenjualan.dariHari.value = true;
                                _laporanController.viewMode.value = 'Rincian';
                              } else if (_laporanController.viewMode.value ==
                                  'Rincian') {
                                final produk = _productController.allProduct
                                    .where((p) => p['key'] == data.value['Id'])
                                    .first;
                                Get.to(() => LihatProduk(produk: produk.obs));
                              }
                            },
                            cells: headList
                                .map((head) => DataCell(head == 'Terjual'
                                    ? Center(
                                        child: Text(data.value[head] == 0
                                            ? '-'
                                            : data.value[head].toString()),
                                      )
                                    : Text(head == 'Bulan' ||
                                            head == 'Tahun' ||
                                            head == 'Tanggal' ||
                                            head == "Id" ||
                                            head == 'Produk'
                                        ? data.value[head].toString()
                                        : data.value[head] == 0
                                            ? '-'
                                            : 'Rp ${_productController.regexNominal(data.value[head].toString())}')))
                                .toList()))
                        .toList()),
                SizedBox(
                  height: Get.height * 0.25,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> initDataBulanan() {
    Map<String, Map<String, dynamic>> dataPenjualan = {};
    final penjualan = _laporanController.penjualan;
    final tahun = _laporanController.tahunTerpilih.value;

    final daftarTahun = penjualan.where((data) {
      final tanggalProduk = int.tryParse(data['tanggal'].split('-')[0]);

      return tanggalProduk == tahun;
    }).toList();

    for (var bulan in _laporanController.namaBulan) {
      final formatBulan = '$bulan $tahun';
      dataPenjualan[formatBulan] = {
        'Bulan': formatBulan,
        'Terjual': 0,
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
      final jumlah = item['jumlah'];
      final hargaBeli = int.tryParse(item['harga_beli']);
      final hargaJual = int.tryParse(item['harga_jual']);
      final modal = jumlah * hargaBeli;
      final omset = jumlah * hargaJual;
      final laba = omset - modal;

      final data = dataPenjualan[formatTanggal]!;
      data['Terjual'] += jumlah;
      data['Modal'] += modal;
      data['Omset'] += omset;
      data['Laba'] += laba;
    }

    return dataPenjualan;
  }

  Map<String, Map<String, dynamic>> iniasiasiDataHarian() {
    Map<String, Map<String, dynamic>> dataPenjualan = {};
    final penjualan = _laporanController.penjualan;
    final bulan = _laporanController.bulanTerpilih.value;
    final tahun = _laporanController.tahunTerpilih.value;
    final indexBulan =
        _laporanController.namaBulan.indexWhere((n) => n == bulan) + 1;
    final jumlahHari = DateTime(tahun, indexBulan + 1, 0).day;
    for (int i = 1; i <= jumlahHari; i++) {
      final tanggal = DateTime(tahun, indexBulan, i);
      final formatTanggal = DateFormat('dd-MM-yyyy').format(tanggal);

      dataPenjualan[formatTanggal] = {
        'Tanggal': formatTanggal,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
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
      int hargaBeli = int.tryParse(item['harga_beli'])!;
      int hargaJual = int.tryParse(item['harga_jual'])!;
      int modal = jumlah * hargaBeli;
      int omset = jumlah * hargaJual;
      int laba = omset - modal;
      final data = dataPenjualan[formatTanggal]!;
      data['Terjual'] += jumlah;
      data['Modal'] += modal;
      data['Omset'] += omset;
      data['Laba'] += laba;
    }

    return dataPenjualan;
  }

  Map<String, Map<String, dynamic>> initDataTahunan() {
    final dataPenjualan = <String, Map<String, dynamic>>{};
    final penjualan = _laporanController.penjualan;
    final daftar =
        penjualan.map((d) => d['tanggal'].split('-')[0]).toSet().toList();

    for (var item in daftar) {
      final tahun = penjualan
          .where((d) => item == d['tanggal'].split('-')[0])
          .toSet()
          .toList();

      dataPenjualan[item] = {
        'Tahun': item,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };

      for (var data in tahun) {
        final jumlah = data['jumlah'];
        final hargaBeli = int.tryParse(data['harga_beli']);
        final hargaJual = int.tryParse(data['harga_jual']);
        final modal = jumlah * hargaBeli;
        final omset = jumlah * hargaJual;
        final laba = omset - modal;
        final update = dataPenjualan[item]!;
        update['Terjual'] += jumlah;
        update['Modal'] += modal;
        update['Omset'] += omset;
        update['Laba'] += laba;
      }
    }

    return dataPenjualan;
  }

  Map<String, Map<String, dynamic>> initRincianData() {
    Map<String, Map<String, dynamic>> dataPenjualan = {};
    final produk = _laporanController.penjualan;
    final splitTanggal =
        int.tryParse(_productController.tanggalHarian.value.split('-')[0])!;
    final splitBulan =
        int.tryParse(_productController.tanggalHarian.value.split('-')[1])!;
    final splitTahun =
        int.tryParse(_productController.tanggalHarian.value.split('-')[2])!;
    final date =
        DateTime(splitTahun, splitBulan, splitTanggal).toString().split(' ')[0];

    final tanggalProduk =
        produk.where((p) => p['tanggal'].split(' ')[0] == date).toList();

    for (var item in tanggalProduk) {
      final itemTanggal = item['tanggal'].split('.')[0];
      final produk = item['produk'];
      final key = item['key'];
      final jumlah = item['jumlah'];
      final hargaBeli = int.tryParse(item['harga_beli'])!;
      final hargaJual = int.tryParse(item['harga_jual'])!;
      int modal = jumlah * hargaBeli;
      int omset = jumlah * hargaJual;
      int laba = omset - modal;

      dataPenjualan[itemTanggal + key] = {
        'Tanggal': itemTanggal,
        'Id': key,
        'Produk': produk,
        'Terjual': jumlah,
        'Modal': modal,
        'Omset': omset,
        'Laba': laba,
      };
    }
    return dataPenjualan;
  }
}
