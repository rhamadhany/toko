import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LaporanPenjualan extends StatelessWidget {
  static final indexLaporan = 1.obs;
  static final headList = ['Tanggal', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  static final headList2 =
      ['Tanggal', 'Produk', 'Terjual', 'Modal', 'Omset', 'Laba'].obs;

  const LaporanPenjualan({super.key});
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

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                showCheckboxColumn: false,
                columnSpacing: 20,
                // horizontalMargin: 12,
                columns:
                    headList.map((e) => DataColumn(label: Text(e))).toList(),
                rows: List.generate(
                  jumlahHari,
                  (index) => DataRow(
                    // selected: false,
                    onSelectChanged: (value) {
                      print('selected $value $index');
                    },
                    cells: [
                      DataCell(Text(DateFormat('dd/MM/yyyy')
                          .format(DateTime(tahun, bulan, index + 1)))),
                      DataCell(Text('${(index + 1) * 10}')),
                      DataCell(Text('${(index + 1) * 5}')),
                      DataCell(Text('${(index + 1) * 15}')),
                      DataCell(Text('${(index + 1) * 10}')),
                    ],
                  ),
                ),
              ),
            ),
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
}
