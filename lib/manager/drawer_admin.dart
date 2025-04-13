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
import 'package:myapp/pengaturan/dialog_keluar_akun.dart';
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
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Get.dialog(AlertDialog(
                      alignment: Alignment.bottomCenter,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.blue)),
                      content: TambahGambar(
                        singleImage: true,
                        resultTap: resultTap,
                        hapusGambar: hapusGambar,
                        image: image.value,
                      )));
                },
                child: image.value == null
                    ? Icon(
                        color: Colors.white,
                        Icons.person,
                        size: (Get.width + Get.height) * 0.15,
                      )
                    : Container(
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              spreadRadius: 5),
                        ]),
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: MemoryImage(image.value!),
                          // child: image.value == null
                          //     ?
                          // Icon(
                          //         color: Colors.white,
                          //         Icons.person,
                          //         size: (Get.width + Get.height) * 0.15,
                          //       )
                          //     : Transform.scale(
                          //         scale: 1.8,
                          //         child: Image.memory(
                          //           image.value!,
                          //           height: (Get.width + Get.height) * 0.15,
                          //           width: (Get.width + Get.height) * 0.15,
                          //         ),
                          //       ),
                        ),
                      ),
              ),
              // Container(
              //   height: (Get.width + Get.height) * 0.175,
              //   clipBehavior: Clip.hardEdge,
              //   decoration: BoxDecoration(
              //       color: Colors.purple, shape: BoxShape.circle),
              //   child: Obx(() => Padding(
              //       padding: EdgeInsets.all(image.value == null ? 8.0 : 0),
              //       child: Center(
              //         child: image.value == null
              //             ? Icon(
              //                 color: Colors.white,
              //                 Icons.person,
              //                 size: (Get.width + Get.height) * 0.15,
              //               )
              //             : Transform.scale(
              //                 scale: 1.8,
              //                 child: Image.memory(
              //                   image.value!,
              //                   height: (Get.width + Get.height) * 0.15,
              //                   width: (Get.width + Get.height) * 0.15,
              //                 ),
              //               ),
              //       ))),
              // )),
              SizedBox(
                height: 50,
              ),
              IntrinsicHeight(
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurStyle: BlurStyle.normal,
                            spreadRadius: 5,
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10)
                      ],
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.dialog(DialogKeluarAkun());
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IntrinsicWidth(
                                    child: Row(
                                      children: [
                                        Text(
                                          Get.find<SplashController>()
                                              .username
                                              .value
                                              .toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.exit_to_app,
                                          color: Colors.red,
                                          size: 30,
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Settings(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
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
                                  'PRODUK',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
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
                                  'LAPORAN',
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
            ],
          ),
        ),
      );
    });
  }

  Future<void> loadFotoProfil() async {
    final username = Get.find<SplashController>().username.value;

    final url = Uri.parse('$domain/load_foto_profil');

    final response = await http.post(url, body: {"username": username});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'sukses') {
        final decode = base64Decode(data['base64']);

        image.value = decode;
        oldImage.value = data['nama'];
      }
    }
  }

  void resultTap(String imagePath) {
    cropImage(imagePath);
  }

  Future<void> cropImage(String newImage) async {
    final bytes = await File(newImage).readAsBytes();
    Get.back();

    Get.dialog(Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.white)),
      child: ImageCropperUI(image: bytes, loadFotoProfil: loadFotoProfil),
    ));
  }

  Future<void> hapusGambar() async {
    Get.back();
    final username = Get.find<SplashController>().username.value;
    final urlDelete = Uri.parse('$domain/hapus_foto_profil');
    await http.post(urlDelete, body: {
      'username': username,
    });
    image.value = null;
  }
}
