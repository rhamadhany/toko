import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/laporan_penjualan.dart';
import 'package:myapp/lihat/lihat_produk.dart';

class PenambahanData extends StatelessWidget {
  PenambahanData({
    super.key,
  });
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headList = _laporanController.viewMode.value == 'Rincian'
          ? ['TANGGAL', 'ID', 'PRODUK', 'JUMLAH', 'MODAL', 'OMSET', 'LABA']
          : _laporanController.viewMode.value == 'Hari'
              ? ['TANGGAL', 'JUMLAH', 'MODAL', 'OMSET', 'LABA']
              : _laporanController.viewMode.value == 'Bulan'
                  ? ['BULAN', 'JUMLAH', 'MODAL', 'OMSET', 'LABA']
                  : ['TAHUN', 'JUMLAH', 'MODAL', 'OMSET', 'LABA'];

      final dataPenambahan = _laporanController.viewMode.value == 'Rincian'
          ? initRincianData()
          : _laporanController.viewMode.value == 'Hari'
              ? iniasiasiDataHarian()
              : _laporanController.viewMode.value == 'Bulan'
                  ? initDataBulanan()
                  : initDataTahunan();
      return SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Transform.scale(
                scale: _laporanController.scaleTransformTable.value,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.blue),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(Colors.blue),
                      showCheckboxColumn: false,
                      columnSpacing: 20,
                      columns: headList
                          .map((head) => DataColumn(
                                  label: Text(
                                head,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white),
                              )))
                          .toList(),
                      rows: dataPenambahan.entries
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
                                      .where(
                                          (p) => p['key'] == data.value['ID'])
                                      .first;

                                  // print(produk);
                                  Get.to(() => LihatProduk(produk: produk.obs));
                                }
                              },
                              cells: headList
                                  .map((head) => DataCell(head == 'JUMLAH'
                                      ? Center(
                                          child: Text(data.value[head] == 0
                                              ? '-'
                                              : data.value[head].toString()),
                                        )
                                      : Text(head == 'BULAN' ||
                                              head == 'TAHUN' ||
                                              head == 'TANGGAL' ||
                                              head == "ID" ||
                                              head == 'PRODUK'
                                          ? data.value[head].toString()
                                          : data.value[head] == 0
                                              ? '-'
                                              : 'Rp ${_productController.regexNominal(data.value[head].toString())}')))
                                  .toList()))
                          .toList()),
                ),
              ),
              SizedBox(
                height: Get.height * 0.25,
              )
            ],
          ),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> initDataBulanan() {
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
        'BULAN': formatBulan,
        'JUMLAH': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
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
      data['JUMLAH'] += jumlah;
      data['MODAL'] += modal;
      data['OMSET'] += omset;
      data['LABA'] += laba;
    }

    return dataPenambahan;
  }

  Map<String, Map<String, dynamic>> iniasiasiDataHarian() {
    Map<String, Map<String, dynamic>> dataPenambahan = {};
    final penambahan = _laporanController.penambahan;
    final bulan = _laporanController.bulanTerpilih.value;
    final tahun = _laporanController.tahunTerpilih.value;
    final indexBulan =
        _laporanController.namaBulan.indexWhere((n) => n == bulan) + 1;
    final jumlahHari = DateTime(tahun, indexBulan + 1, 0).day;
    for (int i = 1; i <= jumlahHari; i++) {
      final tanggal = DateTime(tahun, indexBulan, i);
      final formatTanggal = DateFormat('dd-MM-yyyy').format(tanggal);

      dataPenambahan[formatTanggal] = {
        'TANGGAL': formatTanggal,
        'JUMLAH': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };
    }
    for (var item in penambahan) {
      final tanggal = item['tanggal'].split(' ')[0];
      final tahunParse = int.tryParse(tanggal.split('-')[0])!;
      final bulanParse = int.tryParse(tanggal.split('-')[1])!;
      final hariParse = int.tryParse(tanggal.split('-')[2])!;

      final date = DateTime(tahunParse, bulanParse, hariParse);
      final formatTanggal = DateFormat('dd-MM-yyyy').format(date);
      if (bulanParse != indexBulan || tahunParse != tahun) {
        continue;
      }
      int jumlah = item['stok'];
      int hargaBeli = int.tryParse(item['harga_beli'])!;
      int hargaJual = int.tryParse(item['harga_jual'])!;
      int modal = jumlah * hargaBeli;
      int omset = jumlah * hargaJual;
      int laba = omset - modal;

      final data = dataPenambahan[formatTanggal]!;
      data['JUMLAH'] += jumlah;
      data['MODAL'] += modal;
      data['OMSET'] += omset;
      data['LABA'] += laba;
    }

    return dataPenambahan;
  }

  Map<String, Map<String, dynamic>> initDataTahunan() {
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
        'TAHUN': item,
        'JUMLAH': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };

      for (var data in tahun) {
        final jumlah = data['stok'];
        final hargaBeli = int.tryParse(data['harga_beli']);
        final hargaJual = int.tryParse(data['harga_jual']);
        final modal = jumlah * hargaBeli;
        final omset = jumlah * hargaJual;
        final laba = omset - modal;
        final update = dataPenambahan[item]!;
        update['JUMLAH'] += jumlah;
        update['MODAL'] += modal;
        update['OMSET'] += omset;
        update['LABA'] += laba;
      }
    }

    return dataPenambahan;
  }

  Map<String, Map<String, dynamic>> initRincianData() {
    Map<String, Map<String, dynamic>> dataPenambahan = {};
    final produk = _laporanController.penambahan;
    final splitTanggal =
        int.tryParse(_productController.tanggalHarian.value.split('-')[0])!;
    final splitBulan =
        int.tryParse(_productController.tanggalHarian.value.split('-')[1])!;
    final splitTahun =
        int.tryParse(_productController.tanggalHarian.value.split('-')[2])!;
    final date =
        DateTime(splitTahun, splitBulan, splitTanggal).toString().split(' ')[0];
    // print(produk);
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

      dataPenambahan[itemTanggal + key] = {
        'TANGGAL': itemTanggal,
        'ID': key,
        'PRODUK': produk,
        'JUMLAH': jumlah,
        'MODAL': modal,
        'OMSET': omset,
        'LABA': laba,
      };
    }
    return dataPenambahan;
  }
}
