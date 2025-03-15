import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';
import 'package:myapp/pengaturan/permission_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintingQR {
  PrintingQR({required this.dariBox});
  final RxBool dariBox;
  final ProductController _productController = Get.find();
  final pressAction = false.obs;
  final isLoading = false.obs;
  final progress = ''.obs;
  final finish = false.obs;
  final sdcardPath = '/storage/emulated/0/Toko';
  final fileName = 'QRCode.pdf'.obs;
  final listTextField = RxList<Map<String, dynamic>>([
    {
      'controller': TextEditingController(text: 60.toString()),
      'label': 'QR Perhalaman',
    },
    {
      'controller': TextEditingController(text: 6.toString()),
      'label': 'Lebar QR',
    },
    {
      'controller': TextEditingController(text: 10.toString()),
      'label': 'Spasi',
    },
  ]).obs;
  void dialogQR() {
    Get.dialog(Obx(() {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: Colors.blue,
              // width: 2,
            )),
        title: Text(
          'Simpan QRCode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!pressAction.value)
                ...listTextField.value.map((t) => TextField(
                      controller: t['controller'],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      decoration: InputDecoration(
                          labelText: t['label'], hintText: t['label']),
                    )),
              if (finish.value)
                Text(
                  'Daftar QRCode berhasil disimpan ke $sdcardPath/$fileName',
                  style: TextStyle(fontSize: 14),
                ),
              if (isLoading.value)
                Center(
                  child: LinearProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              if (progress.value != '')
                SizedBox(
                  height: 15,
                ),
              if (progress.value != '' && !finish.value)
                Text(
                  progress.value,
                  style: TextStyle(fontSize: 14),
                )
            ],
          ),
        ),
        actions: [
          if (finish.value)
            ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Oke')),
          if (!pressAction.value)
            ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text('Batal')),
          if (!pressAction.value)
            ElevatedButton(
                onPressed: () async {
                  pressAction.value = true;

                  isLoading.value = true;

                  await Future.delayed(const Duration(seconds: 3));
                  final time = DateTime.now()
                      .toString()
                      .replaceAll(':', '_')
                      .split('.')[0];
                  fileName.value = 'QRCode_$time.pdf';
                  printQR();
                },
                child: Text('Simpan'))
        ],
      );
    }));
  }

  Future<void> printQR() async {
    await PermissionRequest.periksaIzin();
    List<String> daftarQR = [];

    if (dariBox.value) {
      daftarQR = _productController.mapCheckBoxRemove
          .where((i) => i['isSelected'] == 'true')
          .toList()
          .map((f) => f['kode_produk'] as String)
          .toList();
    } else {
      daftarQR = _productController.allProduct
          .map((produk) => produk['kode_produk'].toString())
          .toList();
    }

    final daftarController =
        listTextField.value.map((t) => t['controller']).toList();

    final pdf = pw.Document();
    final qrPerhalaman = int.tryParse(daftarController[0].text) ?? 60;
    for (int i = 0; i < daftarQR.length; i += qrPerhalaman) {
      progress.value = 'Memproses item ke ${i + 1} dari ${daftarQR.length + 1}';
      final itemList = daftarQR.sublist(
          i,
          i + qrPerhalaman > daftarQR.length
              ? daftarQR.length
              : i + qrPerhalaman);

      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.GridView(
            padding: const pw.EdgeInsets.all(8),
            crossAxisCount: int.tryParse(daftarController[1].text) ?? 6,
            mainAxisSpacing: double.tryParse(daftarController[2].text) ?? 10,
            crossAxisSpacing: double.tryParse(daftarController[2].text) ?? 10,
            children: itemList
                .map((item) => pw.Center(
                    child: pw.BarcodeWidget(
                        data: item, barcode: pw.Barcode.qrCode())))
                .toList());
      }));
    }

    final directory = await _getDirectory();
    if (directory == null) return;

    final filePath = '${directory.path}/${fileName.value}';
    final file = File(filePath);

    try {
      await file.writeAsBytes(await pdf.save());
      isLoading.value = false;
      finish.value = true;
    } catch (e) {
      isLoading.value = false;

      Get.snackbar("Error", "Gagal membuat file PDF. Periksa izin penyimpanan.",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  Future<Directory?> _getDirectory() async {
    try {
      final rootPath = await getExternalStorageDirectory();
      if (rootPath == null) return null;
      final backupDir = Directory(sdcardPath);
      if (!backupDir.existsSync()) {
        backupDir.createSync(recursive: true);
      }
      return backupDir;
    } catch (e) {
      Get.snackbar("Error", "Error getting directory: $e.",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);

      return null;
    }
  }
}
