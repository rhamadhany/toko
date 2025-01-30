import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:myapp/controller/product_controller.dart';

class QRScanner extends StatelessWidget {
  QRScanner({super.key});
  final QRScannerController _qrScannerController =
      Get.put(QRScannerController());
  final ProductController _productController = Get.find();
  @override
  Widget build(BuildContext context) {
    _qrScannerController.fromGallery.value = false;
    return Obx(() {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 100),
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
                        color: Colors.grey,
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
                                      animation:
                                          _qrScannerController._animation,
                                      builder: (context, child) {
                                        return Stack(
                                          children: [
                                            MobileScanner(
                                              controller: _qrScannerController
                                                  .mobileScannerController,
                                              onDetect: (barcodeCapture) {
                                                _qrScannerController.sideColors
                                                    .value = Colors.green;
                                                // _productController
                                                //         .pencarianController.text =
                                                //     barcodeCapture
                                                //         .barcodes.first.rawValue!;
                                                final keyScan = barcodeCapture
                                                    .barcodes.first.rawValue;
                                                updateKePencarian(keyScan);

                                                // final code = barcodeCapture
                                                //     .barcodes.first.rawBytes;
                                                // print(code);
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
                            // _qrScannerController.mobileScannerController.stop();
                            _qrScannerController.fromGallery.value = true;
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (image != null) {
                              // try {

                              final data = await _qrScannerController
                                  .mobileScannerController
                                  .analyzeImage(image.path);
                              if (data != null) {
                                final keyScan = data.barcodes.first.rawValue;
                                // updateKePencarian(keyScan);
                                _productController.pencarianController.text =
                                    keyScan!;
                              }
                              // } catch (e) {
                              //   Get.snackbar(
                              //       'Error', 'Error analyzing image: $e');
                              // }
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
        ),
      );
    });
  }

  updateKePencarian(String? keyScan) {
    Get.back();

    final indexKey =
        _productController.allProduct.indexWhere((pr) => pr['key'] == keyScan);

    if (indexKey != -1) {
      final produk = _productController.allProduct[indexKey]['produk'];
      // Get.snackbar('id', produk);
      // Get.back();
      _productController.pencarianController.text = produk;
    } else {
      Get.snackbar('Gagal', '$keyScan tidak ditemukan pada daftar produk',
          snackPosition: SnackPosition.BOTTOM);
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

    scannerListener();
  }

  scannerListener() {
    mobileScannerController.addListener(() {
      final torchState =
          mobileScannerController.torchEnabled; // Ambil state torch saat ini
      if (torchState) {
        flashCamera.value = true;
      } else {
        flashCamera.value = false;
      }
      update();
    });
  }

  @override
  void onClose() {
    super.onClose();
    mobileScannerController.removeListener(() {});

    _animationController.dispose();
  }
}
