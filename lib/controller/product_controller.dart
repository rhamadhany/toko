import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class ProductController extends GetxController {
  Rx<Database?> database = Rx<Database?>(null);

  final showCheckBoxRemove = false.obs;
  final RxList<Map<dynamic, String>> mapCheckBoxRemove =
      <Map<dynamic, String>>[].obs;
  final RxInt bottomIndex = 0.obs;
  final jualController = TextEditingController(text: '0').obs;
  final pencarianController = TextEditingController();

  final searchText = "".obs;
  final RxList<Map<String, dynamic>> listTextField =
      RxList<Map<String, dynamic>>([
    {'label': 'Nama Produk', 'controller': TextEditingController()},
    {
      'label': 'Harga Beli',
      'controller': TextEditingController(),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Harga Jual',
      'controller': TextEditingController(),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Terjual',
      'controller': TextEditingController(text: "0"),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Stok',
      'controller': TextEditingController(),
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Deskripsi',
      'controller': TextEditingController(),
    },
  ]);
  final RxList<Map<String, dynamic>> allProduct = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filterProduct =
      <Map<String, dynamic>>[].obs;
  final showSearch = false.obs;

  final kategoriAktif = 'Semua'.obs;
  final daftarKategori = RxList<Map<String, dynamic>>([
    {'kategori': 'Semua', 'icon': Icons.grid_view.codePoint},
  ]);

  final kategoriAdd = 'Semua'.obs;
  final iconsTerpilih = Icons.grid_view.codePoint.obs;
  final dateFormat = DateFormat('dd-MM-yyyy');
  final tanggalHarian = DateTime.now().toString().split(' ')[0].obs;
  final isNeedRefreshProduk = false.obs;
  final storage = GetStorage();

  dynamic refreshProdukUpdate(String kodeProduk) {
    final produk =
        allProduct.where((p) => p['kode_produk'] == kodeProduk).first;

    return produk['gambar'];
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    tanggalHarian.value =
        dateFormat.format(DateTime.now()).toString().split(' ')[0];
    loadDaftarKategori();

    allProduct.value = await DBHelper.loadProducts();

    filteringProduk();

    kategoriListener();

    pencarianController.addListener(() {
      searchText.value = pencarianController.text;
    });
  }

  void kategoriListener() {
    kategoriAktif.listen((_) {
      if (kategoriAktif.value == 'Semua') {
        refreshFilter();

        generateMapCheckBox();
        update();
      } else {
        filterKategori();
      }
    });
  }

  refreshFilter() {
    filterProduct.value = allProduct
        .where((produk) =>
            produk['produk']
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
            produk['kode_produk'] == searchText.value)
        .toList();
  }

  filterKategori() {
    refreshFilter();
    if (kategoriAktif.value != 'Semua') {
      final cocok = filterProduct
          .where((produk) => produk['kategori'] == kategoriAktif.value)
          .toList();
      filterProduct.value = cocok;
    }
    filterProduct.refresh();

    generateMapCheckBox();
    update();
  }

  // void saveDaftarKategori() async {
  //   storage.write('kategori', daftarKategori);
  // }

  Future<void> saveKategori(String value, Function clearController) async {
    if (daftarKategori.any((kategori) => kategori['kategori'] == value)) {
      Get.snackbar('Error', 'Kategori sudah ada',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      // daftarKategori.add({
      //   'kategori': value,
      //   'icon': iconsTerpilih.value,
      // });
      // print(iconsTerpilih.value);
      final url = Uri.parse('$domain/kategori/add.php');
      final response = await http.post(url, body: {
        'kategori': value,
        'icon': iconsTerpilih.value.toString(),
      });

      if (response.statusCode == 200) {
        final data = response.body;
        final decode = jsonDecode(data);
        if (decode['status'] == 'sukses') {
          Get.snackbar('Berhasil', decode['message'],
              colorText: Colors.white,
              backgroundColor: Colors.green,
              snackPosition: SnackPosition.BOTTOM);
        }
      }

      clearController.call();
      loadDaftarKategori();
    }
  }

  Future<void> deleteKategori(String kategori) async {
    final url = Uri.parse('$domain/kategori/delete.php');
    await http.post(url, body: {
      'kategori': kategori,
    });
    loadDaftarKategori();
    // if ()
  }

  Future<void> loadDaftarKategori() async {
    final url = Uri.parse('$domain/kategori/load.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decode = jsonDecode(response.body);
      // print(decode);
      daftarKategori.value = List<Map<String, dynamic>>.from([
        {'kategori': 'Semua', 'icon': Icons.grid_view.codePoint},
        ...decode
      ]);
    }
    // daftarKategori.value =
    //     List<Map<String, dynamic>>.from(storage.read('kategori') ??
    //         [
    //           {'kategori': 'Semua', 'icon': Icons.grid_view.codePoint}
    //         ]);
  }

  void filteringProduk() {
    filterProduct.value = allProduct;
    searchText.listen((data) {
      if (kategoriAktif.value == 'Semua') {
        filterProduct.value = allProduct
            .where((produk) =>
                produk['produk'].toLowerCase().contains(data.toLowerCase()) ||
                produk['kode_produk'] == data)
            .toList();
      } else {
        filterProduct.value = allProduct
            .where((produk) =>
                (produk['produk'].toLowerCase().contains(data.toLowerCase()) ||
                    produk['kode_produk'] == data) &&
                produk['kategori'] == kategoriAktif.value)
            .toList();
      }
      generateMapCheckBox();
    });
    allProduct.listen((_) {
      filterKategori();
    });
  }

  String hargaProduk(RxMap<String, dynamic> produk) {
    final hargaProduk = produk['harga_jual'].toString();
    final hargaJual = regexNominal(hargaProduk);

    return hargaJual.trim() == "" ? "0" : hargaJual;
  }

  String regexNominal(String value) {
    return value.replaceAll(".", "").replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Future generateMapCheckBox() async {
    if (filterProduct.isEmpty) {
      showCheckBoxRemove.value = false;
      mapCheckBoxRemove.clear();
    } else {
      mapCheckBoxRemove.value = List.generate(
          filterProduct.length,
          (index) => {
                'isSelected': 'false',
                'kode_produk': filterProduct[index]['kode_produk']
              });
    }
  }
}
