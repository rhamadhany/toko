import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/laporan/body_laporan.dart';

class ViewModeLaporan extends StatelessWidget {
  const ViewModeLaporan({
    super.key,
    required LaporanController laporanController,
  }) : _laporanController = laporanController;

  final LaporanController _laporanController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue)),
      title: Card(
        color: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Mode',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_view_day),
            title: const Text('Tahun'),
            trailing: _laporanController.viewMode.value == 'Tahun'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Tahun';
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Bulan'),
            trailing: _laporanController.viewMode.value == 'Bulan'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Bulan';
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Hari'),
            trailing: _laporanController.viewMode.value == 'Hari'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Hari';
              Get.back();
            },
          ),
          if (LaporanPenjualan.indexLaporan.value == 1)
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Transaksi'),
              trailing: _laporanController.viewMode.value == 'Transaksi'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                _laporanController.viewMode.value = 'Transaksi';
                Get.back();
              },
            ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Rincian'),
            trailing: _laporanController.viewMode.value == 'Rincian'
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              _laporanController.viewMode.value = 'Rincian';
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
