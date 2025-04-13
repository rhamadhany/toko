import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/manager/drawer_admin.dart';
import 'package:myapp/manager/manager_controller.dart';
import 'package:uuid/uuid.dart';

class ImageCropperUI extends GetView<ManagerController> {
  ImageCropperUI(
      {super.key, required this.image, required this.loadFotoProfil});
  final Function loadFotoProfil;
  final Uint8List image;
  final scaleGambar = 1.0.obs;
  final valueKey = GlobalKey();
  final xImage = 0.0.obs;
  final yImage = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    double initScale = 1.0;
    return SizedBox(
      height: Get.height * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Foto Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onScaleUpdate: (details) {
                  scaleGambar.value = details.scale * initScale;
                  xImage.value += details.focalPointDelta.dx;
                  yImage.value += details.focalPointDelta.dy;
                },
                onScaleEnd: (detauls) {
                  initScale = scaleGambar.value;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RepaintBoundary(
                    key: valueKey,
                    child:

                        // Obx(() => CircleAvatar(
                        //       radius: 100,
                        //       child: Container(
                        //         width: Get.height * 0.25,
                        //         clipBehavior: Clip.hardEdge,
                        //         decoration: BoxDecoration(
                        //             color: Colors.deepPurple,
                        //             shape: BoxShape.circle),
                        //         child: Transform.translate(
                        //           offset: Offset(xImage.value, yImage.value),
                        //           child: Transform.scale(
                        //               scale: scaleGambar.value,
                        //               child: Image.memory(
                        //                 image,
                        //               )),
                        //         ),
                        //       ),
                        //     ))
                        Container(
                      height: Get.height * 0.25,
                      width: Get.height * 0.25,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple, shape: BoxShape.circle),
                      child: Obx(() => Transform.translate(
                            offset: Offset(xImage.value, yImage.value),
                            child: Transform.scale(
                                scale: scaleGambar.value,
                                child: Image.memory(
                                  image,
                                )),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                  onPressed: () {
                    Get.back();
                    saveCropper();
                  },
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveCropper() async {
    final boundary =
        valueKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      final png = bytes.buffer.asUint8List();

      uploadProfile(png);
    }
  }

  Future<void> uploadProfile(Uint8List image) async {
    final ext = 'png';
    final random = '${DateTime.now().millisecondsSinceEpoch}_${Uuid().v4()}';
    final name = '$random.$ext';

    final encodeGambar = base64Encode(image);
    final uri = Uri.parse('$domain/upload_gambar');
    final response = await http.post(uri, body: {
      'gambar': encodeGambar,
      'nama': name,
    });
    if (response.statusCode == 200) {
      final data = response.body;
      final json = jsonDecode(data);
      if (json['status'] == 'sukses') {
        final gambar = json['gambar'];
        updateFotoProfil(gambar);
      }
    }
  }

  Future<void> updateFotoProfil(String gambar) async {
    if (DrawerAdmin.oldImage.value != '') {
      final urlDelete = Uri.parse('$domain/hapus_gambar');
      await http.post(urlDelete, body: {
        'gambar': jsonEncode([DrawerAdmin.oldImage.value])
      });
    }
    final url = Uri.parse('$domain/update_foto_profil');
    final username = controller.box.read('username') ?? '';
    if (username == '') return;
    await http.post(url, body: {'gambar': gambar, 'username': username});
    loadFotoProfil();
  }
}
