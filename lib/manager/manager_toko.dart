import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/laporan_controller.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/home/beranda_toko.dart';
import 'package:myapp/laporan/body_laporan.dart';
import 'package:myapp/manager/app_bar_manager.dart';
import 'package:myapp/manager/drawer_admin.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/pengaturan/dialog_keluar_akun.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:myapp/produk%20baru/produk_baru.dart';

// class ManagerToko extends GetView<ManagerController> {
//   ManagerToko({super.key});

//   final ProductController _productController = Get.find();
//   final KeranjangController _keranjangController = Get.find();
//   final BiometrikController _biometrikController = Get.find();
//   final LaporanController _laporanController = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     // _biometrikController.initBeometrik();
//     if (!Settings.autentikasiAktif.value) {
//       controller.requestPassword();
//     } else {
//       controller.inisiasiAuthController();
//     }
//     return Obx(() {
//       // if (!Settings.autentikasiAktif.value){}
//       return PopScope(
//         canPop: false,
//         onPopInvokedWithResult: invokePopScope,
//         child: Scaffold(
//           drawer: controller.tabIndex.value == 0 ? DrawerAdmin() : null,
//           appBar: (!_biometrikController.hasAuthenticated.value &&
//                       Settings.autentikasiAktif.value) ||
//                   (!Settings.autentikasiAktif.value &&
//                       !controller.hasAuthenticated.value)
//               ? null
//               : AppBar(
//                   automaticallyImplyLeading:
//                       controller.tabIndex.value == 0 ? true : false,
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   title: AppBarManager()),
//           body: (!_biometrikController.hasAuthenticated.value &&
//                       Settings.autentikasiAktif.value) ||
//                   (!Settings.autentikasiAktif.value &&
//                       !controller.hasAuthenticated.value)
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.blue,
//                   ),
//                 )
//               : TabBarView(controller: controller.tabController, children: [
//                   HomeToko(
//                     isManager: true,
//                   ),
//                   LaporanPenjualan(),
//                 ]),
//           bottomNavigationBar: (!_biometrikController.hasAuthenticated.value &&
//                       Settings.autentikasiAktif.value) ||
//                   (!Settings.autentikasiAktif.value &&
//                       !controller.hasAuthenticated.value)
//               ? null
//               : Container(
//                   color: Colors.blue,
//                   child: TabBar(
//                       labelColor: Colors.white,
//                       unselectedLabelColor:
//                           const Color.fromARGB(185, 255, 255, 255),
//                       tabs: [
//                         Tab(
//                           icon: Icon(Icons.shop),
//                           text: "Produk",
//                         ),
//                         Tab(
//                           icon: Icon(Icons.bar_chart),
//                           text: "Laporan",
//                         ),
//                         // Tab(
//                         //   icon: Icon(Icons.admin_panel_settings),
//                         //   text: "Pengaturan",
//                         // )
//                       ],
//                       controller: controller.tabController),
//                 ),
//           floatingActionButton: (!_biometrikController.hasAuthenticated.value &&
//                       Settings.autentikasiAktif.value) ||
//                   controller.tabIndex.value != 0
//               ? null
//               : FloatingActionButton(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   onPressed: () async {
//                     if (_productController.showCheckBoxRemove.value &&
//                         _productController.filterProduct.isNotEmpty) {
//                       final existSelect = _productController.mapCheckBoxRemove
//                           .any((any) => any['isSelected'] == 'true');

//                       if (!existSelect) {
//                         Get.snackbar("Error", "Pilih setidaknya 1 produk",
//                             snackPosition: SnackPosition.BOTTOM,
//                             colorText: Colors.white,
//                             backgroundColor: Colors.red);
//                         return;
//                       }

//                       bool? confirm = await controller.confirmationDelete();
//                       if (!confirm) {
//                         return;
//                       }
//                       List<String> listKey = [];
//                       for (int i = 0;
//                           i < _productController.filterProduct.length;
//                           i++) {
//                         if (_productController.mapCheckBoxRemove[i]
//                                     ['isSelected'] ==
//                                 'true' &&
//                             _productController.mapCheckBoxRemove[i]
//                                     ['kode_produk'] !=
//                                 "") {
//                           listKey.add(_productController.mapCheckBoxRemove[i]
//                               ['kode_produk']!);
//                         }
//                       }

//                       await _keranjangController.removeProduk(listKey);

//                       await DBHelper.deleteProduct(listKey);
//                       await _keranjangController.loadProduk();
//                       await _productController.generateMapCheckBox();
//                     } else {
//                       _productController.kategoriAdd.value = 'Semua';
//                       for (final controller
//                           in _productController.listTextField) {
//                         if (controller['label'] != 'Terjual') {
//                           controller['controller'].clear();
//                         } else {
//                           controller['controller'].text = "0";
//                         }
//                       }

//                       Get.to(() => NewProduct());
//                     }
//                   },
//                   child: Icon(
//                     _productController.showCheckBoxRemove.value &&
//                             _productController.filterProduct.isNotEmpty
//                         ? Icons.clear
//                         : Icons.add,
//                     color: Colors.white,
//                   ),
//                 ),
//         ),
//       );
//     });
//   }

//   void invokePopScope(didPop, result) {
//     if (_laporanController.showSliderScaler.value) {
//       _laporanController.showSliderScaler.value = false;
//     } else if (_laporanController.viewMode.value == 'Transaksi' &&
//         controller.tabIndex.value == 1) {
//       LaporanPenjualan.dariHari.value = false;
//       _laporanController.viewMode.value = 'Hari';
//     } else if (LaporanPenjualan.dariHari.value &&
//         controller.tabIndex.value == 1 &&
//         LaporanPenjualan.indexLaporan.value == 1) {
//       LaporanPenjualan.dariHari.value = false;
//       _laporanController.viewMode.value = 'Transaksi';
//     } else if (LaporanPenjualan.dariHari.value &&
//         controller.tabIndex.value == 1 &&
//         LaporanPenjualan.indexLaporan.value != 1) {
//       LaporanPenjualan.dariHari.value = false;
//       _laporanController.viewMode.value = 'Hari';
//     } else if (LaporanPenjualan.dariBulan.value &&
//         controller.tabIndex.value == 1) {
//       LaporanPenjualan.dariBulan.value = false;
//       _laporanController.viewMode.value = 'Bulan';
//     } else if (LaporanPenjualan.dariTahun.value &&
//         controller.tabIndex.value == 1) {
//       LaporanPenjualan.dariTahun.value = false;
//       _laporanController.viewMode.value = 'Tahun';
//     } else if (_productController.showCheckBoxRemove.value) {
//       _productController.showCheckBoxRemove.value = false;
//     } else {
//       _biometrikController.hasAuthenticated.value = false;
//       Get.back();
//     }
//   }
// }

class MenuManager extends GetView<ManagerController> {
  const MenuManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          title: Row(
            children: [
              // Icon(Icons.admin_panel_settings),
              // SizedBox(
              //   width: 10,
              // ),
              // Text(
              //   'ADMIN',
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              Spacer(),
              IconButton(
                  onPressed: () {
                    Get.dialog(DialogKeluarAkun());
                  },
                  icon: Icon(Icons.exit_to_app))
            ],
          ),
        ),
        body: DrawerAdmin());
  }
}
