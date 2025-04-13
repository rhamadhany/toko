import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/laporan/body_laporan.dart';
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
              'TANGGAL',
              'ID',
              'PRODUK',
              'KATEGORI',
              'STOK',
              'TERJUAL',
              'MODAL',
              'OMSET',
              'LABA'
            ]
          : _laporanController.viewMode.value == 'Tahun'
              ? ['TAHUN', 'STOK', 'TERJUAL', 'MODAL', 'OMSET', 'LABA']
              : _laporanController.viewMode.value == 'Bulan'
                  ? ['BULAN', 'STOK', 'TERJUAL', 'MODAL', 'OMSET', 'LABA']
                  : ['TANGGAL', 'STOK', 'TERJUAL', 'MODAL', 'OMSET', 'LABA'];
      final dataPerubahan = _laporanController.viewMode.value == 'Rincian'
          ? initDataRincian()
          : _laporanController.viewMode.value == 'Tahun'
              ? initDataTahunan()
              : _laporanController.viewMode.value == 'Bulan'
                  ? initDataBulanan()
                  : initDataHarian();

      return SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Transform.scale(
                scale: _laporanController.scaleTransformTable.value,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: Color.fromARGB(255, 167, 29, 180)),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 20,
                      headingRowColor: WidgetStatePropertyAll(
                          const Color.fromARGB(255, 167, 29, 180)),
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
                      rows: dataPerubahan.entries.map((data) {
                        return DataRow(
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
                                  'Rincian') {
                                final produk = _productController.allProduct
                                    .where((p) =>
                                        p['kode_produk'] == data.value['ID'])
                                    .first;
                                LihatProduk.produk.value = produk;
                                Get.to(() => LihatProduk(
                                      // loadProduk: produk.obs,
                                      isManager: true,
                                    ));
                              } else {
                                _productController.tanggalHarian.value =
                                    data.key;

                                LaporanPenjualan.dariHari.value = true;
                                _laporanController.viewMode.value = 'Rincian';
                              }
                            },
                            cells: headList.map((head) {
                              return DataCell(
                                  Text(data.value[head].toString()));
                            }).toList());
                      }).toList()),
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
        'TANGGAL': formatTanggal,
        'STOK': 0,
        'TERJUAL': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };
      dataPerubahanLama[formatTanggal] = {
        'TANGGAL': formatTanggal,
        'STOK': 0,
        'TERJUAL': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };

      returnDataPerubahan[formatTanggal] = {
        'TANGGAL': formatTanggal,
        'STOK': '-',
        'TERJUAL': '-',
        'MODAL': '-',
        'OMSET': '-',
        'LABA': '-',
      };
    }

    for (var item in daftarProduk) {
      final stokBaru = item['stok_baru'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru']) ?? 0;
      final hargaJualBaru = int.tryParse(item['harga_jual_baru']) ?? 0;
      final modalBaru = stokBaru * hargaBeliBaru;
      final omsetBaru = stokBaru * hargaJualBaru;
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

      dataBaru['STOK'] += stokBaru;
      dataBaru['TERJUAL'] += terjualBaru;
      dataBaru['MODAL'] += modalBaru;
      dataBaru['OMSET'] += omsetBaru;
      dataBaru['LABA'] += labaBaru;

      final stokLama = item['stok_lama'];
      final terjualLama = item['terjual_lama'];
      final hargaBeliLama = int.tryParse(item['harga_beli_lama']) ?? 0;
      final hargaJualLama = int.tryParse(item['harga_jual_lama']) ?? 0;
      final modalLama = stokLama * hargaBeliLama;
      final omsetLama = stokLama * hargaJualLama;
      final labaLama = omsetLama - modalLama;

      final dataLama = dataPerubahanLama[formatTanggalItem]!;

      dataLama['STOK'] += stokLama;
      dataLama['TERJUAL'] += terjualLama;
      dataLama['MODAL'] += modalLama;
      dataLama['OMSET'] += omsetLama;
      dataLama['LABA'] += labaLama;

      final dataReturn = returnDataPerubahan[formatTanggalItem]!;
      dataReturn['STOK'] = dataLama['STOK'] != dataBaru['STOK']
          ? '${dataLama['STOK']} => ${dataBaru['STOK']}'
          : dataBaru['STOK'];
      dataReturn['TERJUAL'] = dataLama['TERJUAL'] != dataBaru['TERJUAL']
          ? "${dataLama['TERJUAL']} => ${dataBaru['TERJUAL']}"
          : dataBaru['TERJUAL'];
      dataReturn['MODAL'] = dataLama['MODAL'] != dataBaru['MODAL']
          ? "Rp ${_productController.regexNominal(dataLama['MODAL'].toString())} => Rp ${_productController.regexNominal(dataBaru['MODAL'].toString())}"
          : 'Rp ${_productController.regexNominal(dataBaru['MODAL'].toString())}';
      dataReturn['OMSET'] = dataLama['OMSET'] != dataBaru['OMSET']
          ? "Rp ${_productController.regexNominal(dataLama['OMSET'].toString())} => Rp ${_productController.regexNominal(dataBaru['OMSET'].toString())}"
          : 'Rp ${_productController.regexNominal(dataBaru['OMSET'].toString())}';
      dataReturn['LABA'] = dataLama['LABA'] != dataBaru['LABA']
          ? "Rp ${_productController.regexNominal(dataLama['LABA'].toString())} => Rp ${_productController.regexNominal(dataBaru['LABA'].toString())}"
          : 'Rp ${_productController.regexNominal(dataBaru['LABA'].toString())}';
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
        'BULAN': formatBulan,
        'STOK': 0,
        'TERJUAL': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };
      dataPerubahanLama[formatBulan] = {
        'BULAN': formatBulan,
        'STOK': 0,
        'TERJUAL': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };

      returnDataPerubahan[formatBulan] = {
        'BULAN': formatBulan,
        'STOK': '-',
        'TERJUAL': '-',
        'MODAL': '-',
        'OMSET': '-',
        'LABA': '-',
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
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru']) ?? 0;
      final hargaJualBaru = int.tryParse(item['harga_jual_baru']) ?? 0;
      final modalBaru = stokBaru * hargaBeliBaru;
      final omsetBaru = stokBaru * hargaJualBaru;
      final labaBaru = omsetBaru - modalBaru;

      final dataBaru = dataPerubahanBaru[formatBulan];
      final dataLama = dataPerubahanLama[formatBulan];
      final dataReturn = returnDataPerubahan[formatBulan]!;
      dataBaru!['STOK'] += stokBaru;
      dataBaru['TERJUAL'] += terjualBaru;
      dataBaru['MODAL'] += modalBaru;
      dataBaru['OMSET'] += omsetBaru;
      dataBaru['LABA'] += labaBaru;

      final stokLama = item['stok_lama'];
      final terjualLama = item['terjual_lama'];
      final hargaBeliLama = int.tryParse(item['harga_beli_lama']) ?? 0;
      final hargaJualLama = int.tryParse(item['harga_jual_lama']) ?? 0;
      final modalLama = stokLama * hargaBeliLama;
      final omsetLama = stokLama * hargaJualLama;
      final labaLama = omsetLama - modalLama;
      dataLama!['STOK'] += stokLama;
      dataLama['TERJUAL'] += terjualLama;
      dataLama['MODAL'] += modalLama;
      dataLama['OMSET'] += omsetLama;
      dataLama['LABA'] += labaLama;
      dataReturn['STOK'] = dataLama['STOK'] != dataBaru['STOK']
          ? '${dataLama['STOK']} => ${dataBaru['STOK']}'
          : dataBaru['STOK'];
      dataReturn['TERJUAL'] = dataLama['TERJUAL'] != dataBaru['TERJUAL']
          ? '${dataLama['TERJUAL']} => ${dataBaru['TERJUAL']}'
          : dataBaru['TERJUAL'];
      dataReturn['MODAL'] = dataLama['MODAL'] != dataBaru['MODAL']
          ? 'Rp ${_productController.regexNominal(dataLama['MODAL'].toString())} => Rp ${_productController.regexNominal(dataBaru['MODAL'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['MODAL'].toString())}';
      dataReturn['OMSET'] = dataLama['OMSET'] != dataBaru['OMSET']
          ? 'Rp ${_productController.regexNominal(dataLama['OMSET'].toString())} => Rp ${_productController.regexNominal(dataBaru['OMSET'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['OMSET'].toString())}';
      dataReturn['LABA'] = dataLama['LABA'] != dataBaru['LABA']
          ? 'Rp ${_productController.regexNominal(dataLama['LABA'].toString())} => Rp ${_productController.regexNominal(dataBaru['LABA'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['LABA'].toString())}';
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
        'TAHUN': tahun,
        'STOK': 0,
        'TERJUAL': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };
      dataPerubahanBaru[tahun] = {
        'TAHUN': tahun,
        'STOK': 0,
        'TERJUAL': 0,
        'MODAL': 0,
        'OMSET': 0,
        'LABA': 0,
      };

      returnDataPerubahan[tahun] = {
        'TAHUN': tahun,
        'STOK': '-',
        'TERJUAL': '-',
        'MODAL': '-',
        'OMSET': '-',
        'LABA': '-',
      };
    }

    for (var item in produk) {
      final tahun = item['tanggal'].split(' ')[0].split('-')[0];
      final stokLama = item['stok_lama'];
      final stokBaru = item['stok_baru'];
      final terjualLama = item['terjual_lama'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru']) ?? 0;
      final hargaJualBaru = int.tryParse(item['harga_jual_baru']) ?? 0;
      final hargaBeliLama = int.tryParse(item['harga_beli_lama']) ?? 0;
      final hargaJualLama = int.tryParse(item['harga_jual_lama']) ?? 0;
      final modalLama = stokLama * hargaBeliLama;
      final modalBaru = stokBaru * hargaBeliBaru;
      final omsetLama = stokLama * hargaJualLama;
      final omsetBaru = stokBaru * hargaJualBaru;
      final labaLama = omsetLama - modalLama;
      final labaBaru = omsetBaru - modalBaru;

      final dataBaru = dataPerubahanBaru[tahun]!;
      final dataLama = dataPerubahanLama[tahun]!;
      final dataReturn = returnDataPerubahan[tahun]!;
      dataBaru['STOK'] += stokBaru;
      dataBaru['TERJUAL'] += terjualBaru;
      dataBaru['MODAL'] += modalBaru;
      dataBaru['OMSET'] += omsetBaru;
      dataBaru['LABA'] += labaBaru;
      dataLama['STOK'] += stokLama;
      dataLama['TERJUAL'] += terjualLama;
      dataLama['MODAL'] += modalLama;
      dataLama['OMSET'] += omsetLama;
      dataLama['LABA'] += labaLama;
      dataReturn['STOK'] = dataLama['STOK'] != dataBaru['STOK']
          ? '${dataLama['STOK']} => ${dataBaru['STOK']}'
          : dataBaru['STOK'];
      dataReturn['TERJUAL'] = dataLama['TERJUAL'] != dataBaru['TERJUAL']
          ? '${dataLama['TERJUAL']} => ${dataBaru['TERJUAL']}'
          : dataBaru['TERJUAL'];
      dataReturn['MODAL'] = dataLama['MODAL'] != dataBaru['MODAL']
          ? 'Rp ${_productController.regexNominal(dataLama['MODAL'].toString())} => Rp ${_productController.regexNominal(dataBaru['MODAL'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['MODAL'].toString())}';
      dataReturn['OMSET'] = dataLama['OMSET'] != dataBaru['OMSET']
          ? 'Rp ${_productController.regexNominal(dataLama['OMSET'].toString())} => Rp ${_productController.regexNominal(dataBaru['OMSET'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['OMSET'].toString())}';
      dataReturn['LABA'] = dataLama['LABA'] != dataBaru['LABA']
          ? 'Rp ${_productController.regexNominal(dataLama['LABA'].toString())} => Rp ${_productController.regexNominal(dataBaru['LABA'].toString())}'
          : 'Rp ${_productController.regexNominal(dataBaru['LABA'].toString())}';
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
      final id = item['kode_produk'];
      final tanggal = item['tanggal'].split('.')[0];
      final stokLama = item['stok_lama'];
      final stokBaru = item['stok_baru'];
      final terjualLama = item['terjual_lama'];
      final terjualBaru = item['terjual_baru'];
      final hargaBeliLama = int.tryParse(item['harga_beli_lama']) ?? 0;
      final hargaBeliBaru = int.tryParse(item['harga_beli_baru']) ?? 0;
      final hargaJualLama = int.tryParse(item['harga_jual_lama']) ?? 0;
      final hargaJualBaru = int.tryParse(item['harga_jual_baru']) ?? 0;
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
        'TANGGAL': tanggal,
        'ID': id,
        'PRODUK': produkLama != produkBaru
            ? '$produkLama => $produkBaru'
            : produkBaru,
        'KATEGORI': kategoriLama != kategoriBaru
            ? '$kategoriLama => $kategoriBaru'
            : kategoriBaru,
        'STOK': stokLama != stokBaru ? '$stokLama => $stokBaru' : stokBaru,
        'TERJUAL': terjualLama != terjualBaru
            ? '$terjualLama => $terjualBaru'
            : terjualBaru,
        'MODAL': modalLama != modalBaru
            ? 'Rp ${_productController.regexNominal(modalLama.toString())} => Rp ${_productController.regexNominal(modalBaru.toString())}'
            : 'Rp ${_productController.regexNominal(modalBaru.toString())}',
        'OMSET': omsetLama != omsetBaru
            ? 'Rp ${_productController.regexNominal(omsetLama.toString())} => Rp ${_productController.regexNominal(omsetBaru.toString())}'
            : 'Rp ${_productController.regexNominal(omsetBaru.toString())}',
        'LABA': labaLama != labaBaru
            ? 'Rp ${_productController.regexNominal(labaLama.toString())} => Rp ${_productController.regexNominal(labaBaru.toString())}'
            : 'Rp ${_productController.regexNominal(labaBaru.toString())}',
      };
    }
    return returnDataPerubahan;
  }
}
