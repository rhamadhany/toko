import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';

class LaporanPenjualan extends StatelessWidget {
  final LaporanController _laporanController = Get.find();
  final ProductController _productController = Get.find();
  static final indexLaporan = 1.obs;
  static final headList = ['Tanggal', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  static final headList2 =
      ['Tanggal', 'Produk', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  LaporanPenjualan({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Data penjualan harian
      // List<Map<String, dynamic>> dataPenjualan = [
      //   {
      //     'tanggal': '2025-01-30',
      //     'terjual': 10,
      //     'modal': 5000,
      //     'omset': 15000,
      //     'laba': 10000
      //   },
      //   {
      //     'tanggal': '2025-01-31',
      //     'terjual': 20,
      //     'modal': 10000,
      //     'omset': 30000,
      //     'laba': 20000
      //   },
      //   // Tambahkan data penjualan harian lainnya
      // ];

      // Fungsi untuk menghitung total penjualan harian

      // Fungsi untuk menampilkan data dengan tanda minus (-) jika data tidak tersedia

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(child: LaporanHarian()),
          ),

          // const Spacer(),
          BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.edit_document), label: 'Perubahan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_checkout), label: 'Penjualan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle), label: 'Penambahan')
            ],
            onTap: (value) {
              indexLaporan.value = value;
            },
            currentIndex: indexLaporan.value,
          ),
        ],
      );
    });
  }

  textEntry(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          softWrap: true,
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  // tableDitampilkan() {
  //   Get.dialog(AlertDialog(content: ListView.builder(itemBuilder: (context, index){
  //     return headList[index]
  //   };),));
  // }
}

class LaporanHarian extends StatelessWidget {
  LaporanHarian({super.key});
  static final LaporanController _laporanController = Get.find();
  static final ProductController _productController = Get.find();
  final indexLaporan = 1.obs;
  final Map<DateTime, Map<String, dynamic>> totalPenjualan = {};

  // static final headList = ['Tanggal', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  // static final headList2 =
  //     ['Tanggal', 'Produk', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tahun = DateTime.now().year;
      final bulan = DateTime.now().month;
      final tanggal = DateTime.now().day;
      final jam = DateTime.now().hour;
      final menit = DateTime.now().minute;
      final detik = DateTime.now().second;
      final jumlahHari = DateTime(tahun, bulan + 1, 0).day;
      return DataTable(
        showCheckboxColumn: false,
        columnSpacing: 12,
        // horizontalMargin: 12,
        columns: LaporanPenjualan.headList
            .map((e) => DataColumn(label: Text(e)))
            .toList(),
        rows: List.generate(
          jumlahHari,
          (index) {
            DateTime tanggal = DateTime(tahun, bulan, index + 1);
            Map<String, dynamic> total = totalPenjualan[tanggal] ?? {};

            return DataRow(
              // selected: false,
              onSelectChanged: (value) {
                // print('selected $value $index');
                // print('modal  ${total['modal']}');
                Get.to(() => RincianHarian());
              },
              cells: [
                DataCell(Text(DateFormat('dd-MM-yyyy')
                    .format(DateTime(tahun, bulan, index + 1)))),
                DataCell(Text(tampilkanData(total['terjual']))),
                DataCell(Text(tampilkanData(total['modal'] != null
                    ? 'Rp ${_productController.regexNominal(total['modal'].toString())}'
                    : total['modal']))),
                DataCell(Text(tampilkanData(total['omset'] != null
                    ? 'Rp ${_productController.regexNominal(total['omset'].toString())}'
                    : total['omset']))),
                DataCell(Text(tampilkanData(total['laba'] != null
                    ? 'Rp ${_productController.regexNominal(total['laba'].toString())}'
                    : total['laba']))),
              ],
            );
          },
        ),
      );
    });
  }

  hitungTotal() {
    _laporanController.penjualan.forEach((item) {
      DateTime tanggal = DateTime.parse(item['tanggal']);
      tanggal = DateTime(tanggal.year, tanggal.month, tanggal.day);

      if (!totalPenjualan.containsKey(tanggal)) {
        totalPenjualan[tanggal] = {
          'terjual': 0,
          'modal': 0,
          'omset': 0,
          'laba': 0,
        };
      }
      Map<String, dynamic> total = totalPenjualan[tanggal] ?? {};
      total['terjual'] = (total['terjual'] ?? 0) + item['jumlah'];
      total['modal'] = (total['modal'] ?? 0) +
          (item['jumlah'] * int.parse(item['harga_beli'].replaceAll('.', '')));
      total['omset'] = (total['omset'] ?? 0) +
          (item['jumlah'] * int.parse(item['harga_jual'].replaceAll('.', '')));
      total['laba'] = (total['omset'] ?? 0) - (total['modal'] ?? 0);
      totalPenjualan[tanggal] = total;
    });
  }

  String tampilkanData(dynamic data) {
    return data != null ? '$data' : '-';
  }
}

class RincianHarian extends StatelessWidget {
  RincianHarian({super.key});
  final headList = ['id', 'produk', 'jumlah', 'modal', 'omset', 'laba'];

  @override
  Widget build(BuildContext context) {
    return DataTable(
        showCheckboxColumn: false,
        columnSpacing: 12,
        columns: headList.map((head) => DataColumn(label: Text(head))).toList(),
        rows: List.generate(
            5,
            (index) => DataRow(cells: [
                  DataCell(Text('1')),
                  DataCell(Text('Produk 1')),
                  DataCell(Text('Produk 1')),
                  DataCell(Text('Produk 1')),
                  DataCell(Text('Produk 1')),
                  DataCell(Text('Produk 1')),
                ])));
  }
}
