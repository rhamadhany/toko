import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
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
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                controller.tabIndex.value == 0 ? 'PRODUK' : 'LAPORAN',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16),
              ),
              Spacer(),
              if (!_productController.showCheckBoxRemove.value &&
                  controller.tabIndex.value == 0)
                dynamicIconAppBar(_productController, true),
              if (_productController.showCheckBoxRemove.value)
                IconButton(
                    onPressed: () {
                      PrintingQR(dariBox: true.obs).dialogQR();
                    },
                    icon: Icon(Icons.print)),
              if (_productController.showCheckBoxRemove.value)
                IconButton(
                    onPressed: () {
                      for (int i = 0;
                          i < _productController.mapCheckBoxRemove.length;
                          i++) {
                        _productController.mapCheckBoxRemove[i]['isSelected'] =
                            _productController.mapCheckBoxRemove[i]
                                        ['isSelected'] ==
                                    'true'
                                ? 'false'
                                : 'true';

                        _productController.mapCheckBoxRemove.refresh();
                      }
                    },
                    icon: const Icon(Icons.select_all, color: Colors.white)),
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
                    icon:
                        const Icon(Icons.calendar_month, color: Colors.white)),
            ],
          ),
        ),
        body: TabBarView(controller: controller.tabController, children: [
          HomeToko(
            isManager: true,
          ),
          LaporanPenjualan()
        ]),
        bottomNavigationBar: Container(
          color: Colors.blue,
          child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: const Color.fromARGB(185, 255, 255, 255),
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
        ),
        floatingActionButton: _biometrikController.tabIndex.value == 3
            ? GenerateItem.textGenerate()
            : (!_biometrikController.hasAuthenticated.value &&
                        Settings.autentikasiAktif.value) ||
                    controller.tabIndex.value != 0
                //  ||
                // _biometrikController.tabIndex.value != 1
                ? null
                : FloatingActionButton(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    onPressed: () async {
                      if (_productController.showCheckBoxRemove.value &&
                          _productController.filterProduct.isNotEmpty) {
                        final existSelect = _productController.mapCheckBoxRemove
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
                              _productController.mapCheckBoxRemove[i]['key'] !=
                                  "") {
                            listKey.add(_productController.mapCheckBoxRemove[i]
                                ['key']!);
                          }
                        }
                        for (int k = 0; k < listKey.length; k++) {
                          await _keranjangController.removeProduk(listKey[k]);
                        }

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
      );
    });
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
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabListener();
  }

  void tabListener() {
    tabController?.addListener(() {
      tabIndex.value = tabController!.index;
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
