import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class LaporanController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Database? database;
  final RxList<Map<String, dynamic>> penjualan = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> perubahan = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> penambahan = <Map<String, dynamic>>[].obs;
  final viewMode = 'Hari'.obs;
  final ProductController _productController = Get.find();
  final bulanTerpilih = ''.obs;
  final bulan = (DateTime.now().month - 1).obs;
  final tahunTerpilih = DateTime.now().year.obs;
  final scaleTransformTable = 1.0.obs;
  final oldScaleTransformTable = 1.0.obs;
  final showSliderScaler = false.obs;
  final showBarLaporan = true.obs;
  TabController? tabController;
  final tabIndex = 0.obs;
  List<String> namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabListener();
    bulanTerpilih.value = namaBulan[bulan.value];
    loadProduk();
  }

  void tabListener() {
    tabController?.addListener(() {
      tabIndex.value = tabController!.index;
    });
  }

  void bulanListener() {
    bulanTerpilih.listen((_) {
      refresh();
    });
  }

  Future<void> loadProduk() async {
    final list = ['perubahan', 'penjualan', 'penambahan'];
    final uri = Uri.parse('$domain/load');
    for (final table in list) {
      try {
        final response = await http.post(uri, body: {
          'tabel': table,
        });
        if (response.statusCode == 200) {
          final decode = jsonDecode(response.body);
          final data = List<Map<String, dynamic>>.from(decode);
          switch (table) {
            case 'perubahan':
              perubahan.value = data;
              break;
            case 'penjualan':
              penjualan.value = data;

              break;
            case 'penambahan':
              penambahan.value = data;
              break;
          }
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> tambahJual(List<Map<String, dynamic>> list, String table) async {
    try {
      for (var produkAdd in list) {
        final indexKey = _productController.allProduct.indexWhere(
            (produk) => produk['kode_produk'] == produkAdd['kode_produk']);
        List<Map<String, dynamic>> listProduk = [];
        if (indexKey != -1) {
          final date = DateTime.now();
          final formattedDate =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';

          listProduk.add({
            'kode_produk': produkAdd['kode_produk'],
            'tanggal': formattedDate,
            'produk': _productController.allProduct[indexKey]['produk'],
            'kategori': _productController.allProduct[indexKey]['kategori'],
            'terjual': produkAdd['terjual'],
            'diskon': produkAdd['diskon'],
            'grosir': produkAdd['grosir'],
            'harga_beli': table == 'penjualan'
                ? produkAdd['harga_beli']
                : _productController.allProduct[indexKey]['harga_beli'],
            'harga_jual': table == 'penjualan'
                ? produkAdd['harga_jual']
                : _productController.allProduct[indexKey]['harga_jual'],
          });
        }

        final encodeValues = jsonEncode(listProduk);
        final uri = Uri.parse('$domain/tambah');
        await http.post(uri, body: {'tabel': table, 'produk': encodeValues});
        await loadProduk();
      }
    } catch (e) {
      Get.snackbar('Error', 'Laporan tambahJual $e',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  void showMenuLaporan() {
    showMenu(
        context: Get.overlayContext!,
        position:
            RelativeRect.fromLTRB(Get.width, Get.height * 0.1, 0, Get.height),
        items: [
          PopupMenuItem(
              child: ListTile(
            leading: Icon(Icons.zoom_out),
            title: Text('ZOOM'),
            onTap: () {
              oldScaleTransformTable.value = scaleTransformTable.value;
              showSliderScaler.value = !showSliderScaler.value;
              Get.back();
            },
          )),
          PopupMenuItem(
              child: ListTile(
            leading: Icon(Icons.navigation),
            onTap: () {
              showBarLaporan.value = !showBarLaporan.value;
              Get.back();
            },
            title: Obx(() {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('BAR'),
                  Spacer(),
                  SizedBox(
                      width: 50,
                      child: Checkbox(
                          activeColor: Colors.blue,
                          value: showBarLaporan.value,
                          onChanged: (_) {
                            showBarLaporan.value = !showBarLaporan.value;
                          })),
                  Spacer(),
                ],
              );
            }),
          ))
        ]);
  }
}
