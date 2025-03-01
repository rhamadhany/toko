import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/main_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/home/animasi_transisi_tab.dart';
import 'package:myapp/home/appbar_my_app.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/laporan/body_laporan.dart';
import 'package:myapp/laporan/kalender_picker.dart';
import 'package:myapp/manager/view_mode_laporan.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/printing_qr.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:myapp/produk%20baru/produk_baru.dart';
import 'package:myapp/tes/generate.dart';

class ManagerToko extends GetView<ManagerController> {
  ManagerToko({super.key});

  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController = Get.find();
  final BiometrikController _biometrikController = Get.find();
  final LaporanController _laporanController = Get.find();
  final MainController _mainController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: controller.tabIndex.value == 0 || controller.canPop,
        onPopInvokedWithResult: (didPop, result) {
          controller.canPop = false;
          if (_laporanController.showSliderScaler.value) {
            _laporanController.showSliderScaler.value = false;
          } else if (_laporanController.viewMode.value == 'Transaksi' &&
              controller.tabIndex.value == 1) {
            LaporanPenjualan.dariHari.value = false;
            _laporanController.viewMode.value = 'Hari';
          } else if (LaporanPenjualan.dariHari.value &&
              controller.tabIndex.value == 1 &&
              LaporanPenjualan.indexLaporan.value == 1) {
            LaporanPenjualan.dariHari.value = false;
            _laporanController.viewMode.value = 'Transaksi';
          } else if (LaporanPenjualan.dariHari.value &&
              controller.tabIndex.value == 1 &&
              LaporanPenjualan.indexLaporan.value != 1) {
            LaporanPenjualan.dariHari.value = false;
            _laporanController.viewMode.value = 'Hari';
          } else if (LaporanPenjualan.dariBulan.value &&
              controller.tabIndex.value == 1) {
            LaporanPenjualan.dariBulan.value = false;
            _laporanController.viewMode.value = 'Bulan';
          } else if (LaporanPenjualan.dariTahun.value &&
              controller.tabIndex.value == 1) {
            LaporanPenjualan.dariTahun.value = false;
            _laporanController.viewMode.value = 'Tahun';
          } else if (_productController.showCheckBoxRemove.value) {
            _productController.showCheckBoxRemove.value = false;
          } else {
            controller.canPop = true;
          }
        },
        child: Scaffold(
          appBar: _laporanController.showBarLaporan.value
              ? AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  title: Row(
                    children: [
                      Text(
                        controller.tabIndex.value == 0
                            ? 'PRODUK'
                            : titleLaporan(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                      Spacer(),
                      if (!_productController.showCheckBoxRemove.value &&
                          controller.tabIndex.value == 0)
                        dynamicIconAppBar(_productController, true),
                      if (_productController.showCheckBoxRemove.value &&
                          controller.tabIndex.value == 0)
                        IconButton(
                            onPressed: () {
                              PrintingQR(dariBox: true.obs).dialogQR();
                            },
                            icon: Icon(Icons.print)),
                      if (_productController.showCheckBoxRemove.value &&
                          controller.tabIndex.value == 0)
                        IconButton(
                            onPressed: () {
                              for (int i = 0;
                                  i <
                                      _productController
                                          .mapCheckBoxRemove.length;
                                  i++) {
                                _productController.mapCheckBoxRemove[i]
                                        ['isSelected'] =
                                    _productController.mapCheckBoxRemove[i]
                                                ['isSelected'] ==
                                            'true'
                                        ? 'false'
                                        : 'true';

                                _productController.mapCheckBoxRemove.refresh();
                              }
                            },
                            icon: const Icon(Icons.select_all,
                                color: Colors.white)),
                      if ((controller.tabIndex.value == 1 &&
                              _laporanController.viewMode.value != 'Tahun' &&
                              LaporanPenjualan.indexLaporan.value != 1) ||
                          (controller.tabIndex.value == 1 &&
                              _laporanController.viewMode.value != 'Rincian' &&
                              LaporanPenjualan.indexLaporan.value == 1))
                        appBarKalenderLaporan(_laporanController),
                      if (controller.tabIndex.value == 1)
                        IconButton(
                            onPressed: () {
                              dialogSwitchOpsi();
                            },
                            icon: const Icon(Icons.calendar_month,
                                color: Colors.white)),
                      if (controller.tabIndex.value == 1)
                        IconButton(
                            onPressed: () {
                              _laporanController.oldScaleTransformTable.value =
                                  _laporanController.scaleTransformTable.value;
                              _laporanController.showSliderScaler.value =
                                  !_laporanController.showSliderScaler.value;
                            },
                            icon: Icon(Icons.zoom_in))
                    ],
                  ),
                )
              : null,
          body: TabBarView(controller: controller.tabController, children: [
            HomeToko(
              isManager: true,
            ),
            // AnimasiTransisiTab(
            //   widgetChild: LaporanPenjualan(),
            //   skalaAnimation: controller.skalaAnimation,
            // )
            LaporanPenjualan()
          ]),
          bottomNavigationBar: _laporanController.showBarLaporan.value
              ? Container(
                  color: Colors.blue,
                  child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          const Color.fromARGB(185, 255, 255, 255),
                      tabs: [
                        Tab(
                          icon: Icon(Icons.shop),
                          text: "Produk",
                        ),
                        Tab(
                          icon: Icon(Icons.bar_chart),
                          text: "Laporan",
                        ),
                      ],
                      controller: controller.tabController),
                )
              : null,
          floatingActionButton: _mainController.tabIndex.value == 3
              ? GenerateItem.textGenerate()
              : (!_biometrikController.hasAuthenticated.value &&
                          Settings.autentikasiAktif.value) ||
                      controller.tabIndex.value != 0
                  ? null
                  : FloatingActionButton(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      onPressed: () async {
                        if (_productController.showCheckBoxRemove.value &&
                            _productController.filterProduct.isNotEmpty) {
                          final existSelect = _productController
                              .mapCheckBoxRemove
                              .any((any) => any['isSelected'] == 'true');

                          if (!existSelect) {
                            Get.snackbar("Error", "Pilih setidaknya 1 produk",
                                snackPosition: SnackPosition.BOTTOM,
                                colorText: Colors.white,
                                backgroundColor: Colors.red);
                            return;
                          }

                          bool? confirm = await controller.confirmationDelete();
                          if (!confirm) {
                            return;
                          }
                          List<String> listKey = [];
                          for (int i = 0;
                              i < _productController.filterProduct.length;
                              i++) {
                            if (_productController.mapCheckBoxRemove[i]
                                        ['isSelected'] ==
                                    'true' &&
                                _productController.mapCheckBoxRemove[i]
                                        ['kode_produk'] !=
                                    "") {
                              listKey.add(_productController
                                  .mapCheckBoxRemove[i]['kode_produk']!);
                            }
                          }

                          await _keranjangController.removeProduk(listKey);

                          await DBHelper.deleteProduct(listKey);
                          await _keranjangController.loadProduk();
                          await _productController.generateMapCheckBox();
                        } else {
                          _productController.kategoriAdd.value = 'Semua';
                          for (final controller
                              in _productController.listTextField) {
                            if (controller['label'] != 'Terjual') {
                              controller['controller'].clear();
                            } else {
                              controller['controller'].text = "0";
                            }
                          }

                          Get.to(() => NewProduct());
                        }
                      },
                      child: Icon(
                        _productController.showCheckBoxRemove.value &&
                                _productController.filterProduct.isNotEmpty
                            ? Icons.clear
                            : Icons.add,
                        color: Colors.white,
                      ),
                    ),
        ),
      );
    });
  }

  String titleLaporan() {
    return _laporanController.viewMode.value == 'Transaksi' &&
            LaporanPenjualan.indexLaporan.value == 1
        ? 'LAPORAN TRANSAKSI'
        : _laporanController.viewMode.value == 'Tahun'
            ? 'LAPORAN TAHUNAN'
            : _laporanController.viewMode.value == 'Bulan'
                ? 'LAPORAN BULANAN'
                : _laporanController.viewMode.value == 'Rincian'
                    ? 'RINCIAN PRODUK'
                    : 'LAPORAN HARIAN';
  }

  TextButton appBarKalenderLaporan(LaporanController laporanController) {
    return TextButton(
        onPressed: () async {
          if (laporanController.viewMode.value == 'Rincian' ||
              laporanController.viewMode.value == 'Transaksi') {
            Get.dialog(KalenderPicker(
              tampilkandaftarTahun: false.obs,
              dariHari: false.obs,
              tampilkanTanggal: true.obs,
              dariRincian: true.obs,
            ));
          } else if (laporanController.viewMode.value == 'Hari') {
            Get.dialog(KalenderPicker(
              tampilkandaftarTahun: false.obs,
              dariHari: true.obs,
              tampilkanTanggal: false.obs,
              dariRincian: false.obs,
            ));
          } else {
            Get.dialog(KalenderPicker(
              tampilkandaftarTahun: true.obs,
              dariHari: false.obs,
              tampilkanTanggal: false.obs,
              dariRincian: false.obs,
            ));
          }
        },
        child: Text(
          (laporanController.viewMode.value == 'Rincian' &&
                      LaporanPenjualan.indexLaporan.value != 1) ||
                  (laporanController.viewMode.value == 'Transaksi' &&
                      LaporanPenjualan.indexLaporan.value == 1)
              ? _productController.tanggalHarian.value
              : laporanController.viewMode.value == 'Hari'
                  ? '${laporanController.bulanTerpilih.value} ${laporanController.tahunTerpilih.value}'
                  : laporanController.tahunTerpilih.value.toString(),
          style: const TextStyle(color: Colors.white),
        ));
  }

  void dialogSwitchOpsi() {
    Get.dialog(ViewModeLaporan(laporanController: _laporanController));
  }
}

class ManagerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  final tabIndex = 0.obs;
  bool canPop = true;
  final skalaAnimation = 1.0.obs;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabListener();
  }

  void tabListener() {
    tabController?.addListener(() async {
      tabIndex.value = tabController!.index;
      if (tabController!.indexIsChanging) {
        for (int i = 0; i < 60; i++) {
          if (i < 30) {
            skalaAnimation.value -= 0.01;
          } else {
            skalaAnimation.value += 0.01;
          }
          await Future.delayed(Duration(milliseconds: 10));
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    tabController?.removeListener(() {});
    tabController?.dispose();
  }

  Future<bool> confirmationDelete() async {
    final bool? confirm = await Get.dialog<bool?>(AlertDialog(
      title: const Text("Konfirmasi"),
      content: const Text("Anda yakin untuk menghapus produk ini?"),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text("Batal")),
        ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text("Ya")),
      ],
    ));
    return confirm ?? false;
  }
}
