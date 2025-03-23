import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/manager/image_cropper_ui.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:myapp/manager/page_laporan_admin.dart';
import 'package:myapp/manager/page_produk_admin.dart';
import 'package:myapp/pengaturan/settings.dart';
import 'package:myapp/produk%20baru/tambah_gambar.dart';
import 'package:http/http.dart' as http;

class DrawerAdmin extends GetView<ManagerController> {
  DrawerAdmin({
    super.key,
  });
  final image = Rx<Uint8List?>(null);
  static final oldImage = ''.obs;
  @override
  Widget build(BuildContext context) {
    loadFotoProfil();
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spacer(),
          Expanded(
            child: InkWell(
                onTap: () {
                  Get.dialog(AlertDialog(
                      alignment: Alignment.bottomCenter,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.blue)),
                      content: TambahGambar(
                        singleImage: true,
                        resultTap: resultTap,
                      )));
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: Colors.purple, shape: BoxShape.circle),
                  child: Obx(() => Padding(
                      padding: EdgeInsets.all(image.value == null ? 8.0 : 0),
                      child: image.value == null
                          ? Icon(
                              color: Colors.white,
                              Icons.person,
                              size: (Get.width + Get.height) * 0.1,
                            )
                          : Image.memory(image.value!))),
                )),
          ),
          // SizedBox(
          //   height: 10,
          // ),
          // Spacer(),

          IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   Get.find<SplashController>().username.value.toUpperCase(),
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: (Get.width + Get.height) * 0.015,
                    //       color: Colors.white),
                    // ),

                    Settings(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.white,
                          child: TextButton.icon(
                            icon: Icon(
                              Icons.shop,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Get.to(() => PageProdukAdmin());
                            },
                            label: Text(
                              'Produk',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.white,
                          child: TextButton.icon(
                            icon: Icon(
                              Icons.bar_chart,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Get.to(() => PageLaporanAdmin());
                            },
                            label: Text(
                              'Laporan',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          // Spacer(),
          // KeluarAkun(),
        ],
      ),
    );
  }

  Future<void> loadFotoProfil() async {
    final url = Uri.parse('$domain/user/load_foto_profil.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final decode = base64Decode(data['base64']);

      image.value = decode;
      oldImage.value = data['nama'];
    }
  }

  void resultTap(String image) {
    cropImage(image);
  }

  Future<void> cropImage(String newImage) async {
    final bytes = await File(newImage).readAsBytes();
    Get.back();
    // await Future.delayed(const Duration(seconds: 1));
    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white)),
      child: ImageCropperUI(
        image: bytes,
        // reloadProfile: loadFotoProfil,
      ),
    ));
  }
}
