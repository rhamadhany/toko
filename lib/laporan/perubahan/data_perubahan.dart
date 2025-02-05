import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/laporan_penjualan.dart';
import 'package:myapp/lihat/lihat_produk.dart';

class DataPerubahan extends StatelessWidget {
  DataPerubahan({super.key});
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headList = _laporanController.viewMode.value == 'Rincian'
          ? [
              'Tanggal',
              'Id',
              'Produk',
              'Kategori',
              'Terjual',
              'Modal',
              'Omset',
              'Laba'
            ]
          : _laporanController.viewMode.value == 'Hari'
              ? ['Tanggal', 'Stok', 'Terjual', 'Modal', 'Omset', 'Laba']
              : _laporanController.viewMode.value == 'Bulan'
                  ? ['Bulan', 'Stok', 'Terjual', 'Modal', 'Omset', 'Laba']
                  : ['Tahun', 'Stok', 'Terjual', 'Modal', 'Omset', 'Laba'];
      final dataPerubahan = _laporanController.viewMode.value == 'Rincian'
          ? initDataRincian()
          : _laporanController.viewMode.value == 'Hari'
              ? initDataHarian()
              : _laporanController.viewMode.value == 'Bulan'
                  ? initDataBulanan()
                  : initDataTahunan();

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
              rows: dataPerubahan.entries.map((data) {
                return DataRow(
                    onSelectChanged: (_) {
                      if (_laporanController.viewMode.value == 'Tahun') {
                        _laporanController.tahunTerpilih.value =
                            int.tryParse(data.key)!;
                        _laporanController.viewMode.value = 'Bulan';
                        LaporanPenjualan.dariTahun.value = true;
                      } else if (_laporanController.viewMode.value == 'Bulan') {
                        LaporanPenjualan.dariBulan.value = true;

                        _laporanController.bulanTerpilih.value =
                            data.key.split(' ')[0];
                        _laporanController.viewMode.value = 'Hari';
                      } else if (_laporanController.viewMode.value == 'Hari') {
                        _productController.tanggalHarian.value = data.key;

                        print(_productController.tanggalHarian.value);
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
                    cells: headList.map((head) {
                      return DataCell(Text(data.value[head].toString()));
                    }).toList());
              }).toList()),
        ),
      );
    });
  }

  Map<String, Map<String, dynamic>> initDataHarian() {
    Map<String, Map<String, dynamic>> dataPerubahanBaru = {};
    Map<String, Map<String, dynamic>> dataPerubahanLama = {};
    Map<String, Map<String, dynamic>> returnDataPerubahan = {};

    final produk = _laporanController.perubahan;
    final tahun = _laporanController.tahunTerpilih.value;
    final bulan = _laporanController.bulanTerpilih.value;
    final indexBulan =
        _laporanController.namaBulan.indexWhere((b) => b == bulan) + 1;
    final daftarTanggal = DateTime(tahun, indexBulan + 1, 0).day;
    final formatTanggal =
        DateFormat('MM-yyyy').format(DateTime(tahun, indexBulan, 1));

    final daftarProduk = produk.where((p) {
      final d = p['tanggal'].split(' ')[0].split('-');
      final tanggal = '${d[1]}-${d[0]}';

      return tanggal == formatTanggal;
    }).toList();

    for (int i = 1; i <= daftarTanggal; i++) {
      final parserTanggal = DateTime(tahun, indexBulan, i);
      final formatTanggal = DateFormat('dd-MM-yyyy').format(parserTanggal);

      dataPerubahanBaru[formatTanggal] = {
        'Tanggal': formatTanggal,
        'Stok': 0,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };
      dataPerubahanLama[formatTanggal] = {
        'Tanggal': formatTanggal,
        'Stok': 0,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };

      returnDataPerubahan[formatTanggal] = {
        'Tanggal': formatTanggal,
        'Stok': '-',
        'Terjual': '-',
        'Modal': '-',
        'Omset': '-',
        'Laba': '-',
      };
    }

    for (var item in daftarProduk) {
      final stokBaru = item['stok_baru'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru']);
      final hargaJualBaru = int.tryParse(item['harga_jual_baru']);
      final modalBaru = stokBaru * hargaBeliBaru!;
      final omsetBaru = stokBaru * hargaJualBaru!;
      final labaBaru = omsetBaru - modalBaru;

      final tanggalItem = item['tanggal'].split(' ')[0];
      final tahunParse = int.tryParse(tanggalItem.split('-')[0])!;
      final bulanParse = int.tryParse(tanggalItem.split('-')[1])!;
      final hariParse = int.tryParse(tanggalItem.split('-')[2])!;

      final date = DateTime(tahunParse, bulanParse, hariParse);
      final formatTanggalItem = DateFormat('dd-MM-yyyy').format(date);
      if (bulanParse != indexBulan || tahunParse != tahun) {
        continue;
      }

      final dataBaru = dataPerubahanBaru[formatTanggalItem]!;

      dataBaru['Stok'] += stokBaru;
      dataBaru['Terjual'] += terjualBaru;
      dataBaru['Modal'] += modalBaru;
      dataBaru['Omset'] += omsetBaru;
      dataBaru['Laba'] += labaBaru;

      final stokLama = item['stok_lama'];
      final terjualLama = item['terjual_lama'];
      final hargaBeliLama = int.tryParse(item['harga_beli_lama']);
      final hargaJualLama = int.tryParse(item['harga_jual_lama']);
      final modalLama = stokLama * hargaBeliLama!;
      final omsetLama = stokLama * hargaJualLama!;
      final labaLama = omsetLama - modalLama;

      final dataLama = dataPerubahanLama[formatTanggalItem]!;

      dataLama['Stok'] += stokLama;
      dataLama['Terjual'] += terjualLama;
      dataLama['Modal'] += modalLama;
      dataLama['Omset'] += omsetLama;
      dataLama['Laba'] += labaLama;

      final dataReturn = returnDataPerubahan[formatTanggalItem]!;
      dataReturn['Stok'] = dataLama['Stok'] != dataBaru['Stok']
          ? '${dataLama['Stok']} => ${dataBaru['Stok']}'
          : dataBaru['Stok'];
      dataReturn['Terjual'] = dataLama['Terjual'] != dataBaru['Terjual']
          ? "${dataLama['Terjual']} => ${dataBaru['Terjual']}"
          : dataBaru['Terjual'];
      dataReturn['Modal'] = dataLama['Modal'] != dataBaru['Modal']
          ? "Rp ${_productController.regexNominal(dataLama['Modal'].toString())} => Rp ${_productController.regexNominal(dataBaru['Modal'].toString())}"
          : 'Rp ${_productController.regexNominal(dataBaru['Modal'].toString())}';
      dataReturn['Omset'] = dataLama['Omset'] != dataBaru['Omset']
          ? "Rp ${_productController.regexNominal(dataLama['Omset'].toString())} => Rp ${_productController.regexNominal(dataBaru['Omset'].toString())}"
          : 'Rp ${_productController.regexNominal(dataBaru['Omset'].toString())}';
      dataReturn['Laba'] = dataLama['Laba'] != dataBaru['Laba']
          ? "Rp ${_productController.regexNominal(dataLama['Laba'].toString())} => Rp ${_productController.regexNominal(dataBaru['Laba'].toString())}"
          : 'Rp ${_productController.regexNominal(dataBaru['Laba'].toString())}';
    }

    return returnDataPerubahan;
  }

  Map<String, Map<String, dynamic>> initDataBulanan() {
    Map<String, Map<String, dynamic>> dataPerubahanBaru = {};
    Map<String, Map<String, dynamic>> dataPerubahanLama = {};
    Map<String, Map<String, dynamic>> returnDataPerubahan = {};

    final produk = _laporanController.perubahan;
    final tahunTerpilih = _laporanController.tahunTerpilih.value;

    final daftarProduk = produk
        .where((p) {
          final d = p['tanggal'].split(' ')[0].split('-');
          final tanggal = '${d[0]}';
          return tanggal == tahunTerpilih.toString();
        })
        .toSet()
        .toList();

    for (var bulan in _laporanController.namaBulan) {
      final formatBulan = '$bulan $tahunTerpilih';

      dataPerubahanBaru[formatBulan] = {
        'Bulan': formatBulan,
        'Stok': 0,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };
      dataPerubahanLama[formatBulan] = {
        'Bulan': formatBulan,
        'Stok': 0,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };

      returnDataPerubahan[formatBulan] = {
        'Bulan': formatBulan,
        'Stok': '-',
        'Terjual': '-',
        'Modal': '-',
        'Omset': '-',
        'Laba': '-',
      };
    }

    for (var item in daftarProduk) {
      final parseDate = item['tanggal'].toString().split(' ')[0].split('-');
      final parseBulan = int.tryParse(parseDate[1])!;
      final parseTahun = parseDate[0];
      final namaBulan = _laporanController.namaBulan[parseBulan - 1];

      if (parseTahun.toString() != tahunTerpilih.toString()) continue;
      final formatBulan = '$namaBulan $parseTahun';
      final stokBaru = item['stok_baru'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru']);
      final hargaJualBaru = int.tryParse(item['harga_jual_baru']);
      final modalBaru = stokBaru * hargaBeliBaru!;
      final omsetBaru = stokBaru * hargaJualBaru!;
      final labaBaru = omsetBaru - modalBaru;

      final dataBaru = dataPerubahanBaru[formatBulan];
      final dataLama = dataPerubahanLama[formatBulan];
      final dataReturn = returnDataPerubahan[formatBulan]!;
      dataBaru!['Stok'] += stokBaru;
      dataBaru['Terjual'] += terjualBaru;
      dataBaru['Modal'] += modalBaru;
      dataBaru['Omset'] += omsetBaru;
      dataBaru['Laba'] += labaBaru;

      final stokLama = item['stok_lama'];
      final terjualLama = item['terjual_lama'];
      final hargaBeliLama = int.tryParse(item['harga_beli_lama']);
      final hargaJualLama = int.tryParse(item['harga_jual_lama']);
      final modalLama = stokLama * hargaBeliLama!;
      final omsetLama = stokLama * hargaJualLama!;
      final labaLama = omsetLama - modalLama;
      dataLama!['Stok'] += stokLama;
      dataLama['Terjual'] += terjualLama;
      dataLama['Modal'] += modalLama;
      dataLama['Omset'] += omsetLama;
      dataLama['Laba'] += labaLama;
      dataReturn['Stok'] = dataLama['Stok'] != dataBaru['Stok']
          ? '${dataLama['Stok']} => ${dataBaru['Stok']}'
          : dataBaru['Stok'];
      dataReturn['Terjual'] = dataLama['Terjual'] != dataBaru['Terjual']
          ? '${dataLama['Terjual']} => ${dataBaru['Terjual']}'
          : dataBaru['Terjual'];
      dataReturn['Modal'] = dataLama['Modal'] != dataBaru['Modal']
          ? 'Rp ${_productController.regexNominal(dataLama['Modal'].toString())} => Rp ${_productController.regexNominal(dataBaru['Modal'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['Modal'].toString())}';
      dataReturn['Omset'] = dataLama['Omset'] != dataBaru['Omset']
          ? 'Rp ${_productController.regexNominal(dataLama['Omset'].toString())} => Rp ${_productController.regexNominal(dataBaru['Omset'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['Omset'].toString())}';
      dataReturn['Laba'] = dataLama['Laba'] != dataBaru['Laba']
          ? 'Rp ${_productController.regexNominal(dataLama['Laba'].toString())} => Rp ${_productController.regexNominal(dataBaru['Laba'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['Laba'].toString())}';
    }

    return returnDataPerubahan;
  }

  Map<String, Map<String, dynamic>> initDataTahunan() {
    Map<String, Map<String, dynamic>> dataPerubahanBaru = {};
    Map<String, Map<String, dynamic>> dataPerubahanLama = {};
    Map<String, Map<String, dynamic>> returnDataPerubahan = {};

    final produk = _laporanController.perubahan;

    final daftarTahun = produk
        .map((p) => p['tanggal'].split(' ')[0].split('-')[0])
        .toSet()
        .toList();

    for (var tahun in daftarTahun) {
      dataPerubahanLama[tahun] = {
        'Tahun': tahun,
        'Stok': 0,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };
      dataPerubahanBaru[tahun] = {
        'Tahun': tahun,
        'Stok': 0,
        'Terjual': 0,
        'Modal': 0,
        'Omset': 0,
        'Laba': 0,
      };

      returnDataPerubahan[tahun] = {
        'Tahun': tahun,
        'Stok': '-',
        'Terjual': '-',
        'Modal': '-',
        'Omset': '-',
        'Laba': '-',
      };
    }

    for (var item in produk) {
      final tahun = item['tanggal'].split(' ')[0].split('-')[0];
      final stokLama = item['stok_lama'];
      final stokBaru = item['stok_baru'];
      final terjualLama = item['terjual_lama'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru'])!;
      final hargaJualBaru = int.tryParse(item['harga_jual_baru'])!;
      final hargaBeliLama = int.tryParse(item['harga_beli_lama'])!;
      final hargaJualLama = int.tryParse(item['harga_jual_lama'])!;
      final modalLama = stokLama * hargaBeliLama;
      final modalBaru = stokBaru * hargaBeliBaru;
      final omsetLama = stokLama * hargaJualLama;
      final omsetBaru = stokBaru * hargaJualBaru;
      final labaLama = omsetLama - modalLama;
      final labaBaru = omsetBaru - modalBaru;

      final dataBaru = dataPerubahanBaru[tahun]!;
      final dataLama = dataPerubahanLama[tahun]!;
      final dataReturn = returnDataPerubahan[tahun]!;
      dataBaru['Stok'] += stokBaru;
      dataBaru['Terjual'] += terjualBaru;
      dataBaru['Modal'] += modalBaru;
      dataBaru['Omset'] += omsetBaru;
      dataBaru['Laba'] += labaBaru;
      dataLama['Stok'] += stokLama;
      dataLama['Terjual'] += terjualLama;
      dataLama['Modal'] += modalLama;
      dataLama['Omset'] += omsetLama;
      dataLama['Laba'] += labaLama;
      dataReturn['Stok'] = dataLama['Stok'] != dataBaru['Stok']
          ? '${dataLama['Stok']} => ${dataBaru['Stok']}'
          : dataBaru['Stok'];
      dataReturn['Terjual'] = dataLama['Terjual'] != dataBaru['Terjual']
          ? '${dataLama['Terjual']} => ${dataBaru['Terjual']}'
          : dataBaru['Terjual'];
      dataReturn['Modal'] = dataLama['Modal'] != dataBaru['Modal']
          ? 'Rp ${_productController.regexNominal(dataLama['Modal'].toString())} => Rp ${_productController.regexNominal(dataBaru['Modal'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['Modal'].toString())}';
      dataReturn['Omset'] = dataLama['Omset'] != dataBaru['Omset']
          ? 'Rp ${_productController.regexNominal(dataLama['Omset'].toString())} => Rp ${_productController.regexNominal(dataBaru['Omset'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['Omset'].toString())}';
      dataReturn['Laba'] = dataLama['Laba'] != dataBaru['Laba']
          ? 'Rp ${_productController.regexNominal(dataLama['Laba'].toString())} => Rp ${_productController.regexNominal(dataBaru['Laba'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['Laba'].toString())}';
    }

    return returnDataPerubahan;
  }

  Map<String, Map<String, dynamic>> initDataRincian() {
    Map<String, Map<String, dynamic>> returnDataPerubahan = {};

    final produk = _laporanController.perubahan;
    // final tanggalHarian = _productController.tanggalHarian.value;
    final splitTanggal =
        int.tryParse(_productController.tanggalHarian.value.split('-')[0])!;
    final splitBulan =
        int.tryParse(_productController.tanggalHarian.value.split('-')[1])!;
    final splitTahun =
        int.tryParse(_productController.tanggalHarian.value.split('-')[2])!;
    final date =
        DateTime(splitTahun, splitBulan, splitTanggal).toString().split(' ')[0];

    // print(date);
    final daftarProduk = produk.where((p) {
      final t = p['tanggal'].split(' ')[0];
      return t == date;
    }).toList();

    for (var item in daftarProduk) {
      final id = item['key'];
      final tanggal = item['tanggal'].split('.')[0];
      final stokLama = item['stok_lama'];
      final stokBaru = item['stok_baru'];
      final terjualLama = item['terjual_lama'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliLama = int.tryParse(item['harga_beli_lama'])!;
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru'])!;
      final hargaJualLama = int.tryParse(item['harga_jual_lama'])!;
      final hargaJualBaru = int.tryParse(item['harga_jual_baru'])!;
      final modalLama = stokLama * hargaBeliLama;
      final modalBaru = stokBaru * hargaBeliBaru;
      final omsetLama = stokLama * hargaJualLama;
      final omsetBaru = stokBaru * hargaJualBaru;
      final labaLama = omsetLama - modalLama;
      final labaBaru = omsetBaru - modalBaru;
      final produkLama = item['produk_lama'];
      final produkBaru = item['produk_baru'];
      final kategoriLama = item['kategori_lama'];
      final kategoriBaru = item['kategori_baru'];
      returnDataPerubahan['$tanggal$key'] = {
        'Tanggal': tanggal,
        'Id': id,
        'Produk': produkLama != produkBaru
            ? '$produkLama => $produkBaru'
            : produkBaru,
        'Kategori': kategoriLama != kategoriBaru
            ? '$kategoriLama => $kategoriBaru'
            : kategoriBaru,
        'Stok': stokLama != stokBaru ? '$stokLama => $stokBaru' : stokBaru,
        'Terjual': terjualLama != terjualBaru
            ? '$terjualLama => $terjualBaru'
            : terjualBaru,
        'Modal': modalLama != modalBaru
            ? 'Rp ${_productController.regexNominal(modalLama.toString())} => Rp ${_productController.regexNominal(modalBaru.toString())}'
            : 'Rp ${_productController.regexNominal(modalBaru.toString())}',
        'Omset': omsetLama != omsetBaru
            ? 'Rp ${_productController.regexNominal(omsetLama.toString())} => Rp ${_productController.regexNominal(omsetBaru.toString())}'
            : 'Rp ${_productController.regexNominal(omsetBaru.toString())}',
        'Laba': labaLama != labaBaru
            ? 'Rp ${_productController.regexNominal(labaLama.toString())} => Rp ${_productController.regexNominal(labaBaru.toString())}'
            : 'Rp ${_productController.regexNominal(labaBaru.toString())}',
      };
    }
    return returnDataPerubahan;
  }
}
