import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myapp/controller/keranjang_controller.dart';
import 'package:myapp/controller/product_controller.dart';

import 'package:myapp/lihat/lihat_produk.dart';

class QRScanner extends StatelessWidget {
  QRScanner({super.key, required this.dariKeranjang, required this.isManager});
  final QRScannerController _qrScannerController = Get.find();
  final ProductController _productController = Get.find();
  final KeranjangController _keranjangController = Get.find();
  final bool dariKeranjang;
  final bool isManager;
  final hasShowSnackBar = false.obs;
  @override
  Widget build(BuildContext context) {
    _qrScannerController.fromGallery.value = false;
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 100),
          child: Column(
            children: [
              const Text(
                'Scan QRCode',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.white),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  height: Get.height * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(
                        color: _qrScannerController.sideColors.value,
                        width: 5,
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        height: Get.height * 0.5,
                        child: _qrScannerController.fromGallery.value
                            ? null
                            : Stack(
                                children: [
                                  AnimatedBuilder(
                                    animation: _qrScannerController._animation,
                                    builder: (context, child) {
                                      return Stack(
                                        children: [
                                          MobileScanner(
                                            controller: _qrScannerController
                                                .mobileScannerController,
                                            onDetect: (barcodeCapture) async {
                                              _qrScannerController.sideColors
                                                  .value = Colors.blue;

                                              final keyScan = barcodeCapture
                                                  .barcodes.first.rawValue;
                                              await updateKePencarian(keyScan);
                                            },
                                            onDetectError: (barcode, error) {
                                              _qrScannerController.sideColors
                                                  .value = Colors.red;
                                            },
                                          ),
                                          Positioned(
                                            top: _qrScannerController
                                                    ._animation.value *
                                                Get.height *
                                                0.5,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red.withAlpha(50),
                                                    Colors.red,
                                                    Colors.red.withAlpha(50),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () {
                          _qrScannerController.flashCamera.value =
                              !_qrScannerController.flashCamera.value;
                          _qrScannerController.mobileScannerController
                              .toggleTorch();
                        },
                        icon: Icon(
                            _qrScannerController.flashCamera.value
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: Colors.white,
                            size: 35)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        onPressed: () async {
                          _qrScannerController.fromGallery.value = true;
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (image != null) {
                            final data = await _qrScannerController
                                .mobileScannerController
                                .analyzeImage(image.path);
                            if (data != null) {
                              final keyScan = data.barcodes.first.rawValue;
                              updateKePencarian(keyScan);
                            } else {
                              _qrScannerController.fromGallery.value = false;
                            }
                          } else {
                            _qrScannerController.fromGallery.value = false;
                          }
                        },
                        icon: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 35,
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Future<void> updateKePencarian(String? keyScan) async {
    if (keyScan != null) {
      final indexKey = _productController.allProduct
          .indexWhere((pr) => pr['kode_produk'] == keyScan);

      if (indexKey != -1) {
        final produk = _productController.allProduct[indexKey];
        final sisa = produk['stok'] - produk['terjual'];
        if (dariKeranjang) {
          final gDiskon = _keranjangController.getDiskon(produk['kode_produk']);
          await _keranjangController.langsungtambahkeKeranjang(
              sisa, produk.obs, gDiskon['diskon'], gDiskon['min_produk']);
        } else {
          Get.back(closeOverlays: true);

          Get.to(() => LihatProduk(
                isManager: isManager,
                loadProduk: produk.obs,
              ));
        }
      } else {
        _qrScannerController.fromGallery.value = false;
        hasShowSnackBar.value = true;
        if (!hasShowSnackBar.value) {
          Get.snackbar('Gagal', '$keyScan tidak ditemukan pada daftar produk',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
          await Future.delayed(const Duration(seconds: 3));
          hasShowSnackBar.value = false;
        }
      }
    } else {
      hasShowSnackBar.value = true;
      if (!hasShowSnackBar.value) {
        Get.snackbar('Gagal', 'Tidak berhasil memindai gambar',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red);
        await Future.delayed(const Duration(seconds: 3));
        hasShowSnackBar.value = false;
      }
    }
  }
}

class QRScannerController extends GetxController
    with GetTickerProviderStateMixin {
  final MobileScannerController mobileScannerController =
      MobileScannerController();
  final flashCamera = false.obs;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final sideColors = Colors.transparent.obs;
  final fromGallery = false.obs;
  @override
  void onInit() {
    super.onInit();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void onClose() {
    super.onClose();
    mobileScannerController.removeListener(() {});

    _animationController.dispose();
  }
}
