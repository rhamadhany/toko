import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/splash_login.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/printing_qr.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static final autentikasiAktif = false.obs;
  static final BiometrikController _biometrikController = Get.find();
  static final SplashController _splashController = Get.find();
  static final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicHeight(
        child: Container(
          width: Get.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // containerChild(
                //   ListTile(
                //     onTap: () {
                //       Get.to(() => ManagerToko(),
                //           transition: Transition.zoom,
                //           duration: Duration(milliseconds: 500));
                //     },
                //     leading: Icon(
                //       Icons.warehouse,
                //       color: Colors.black,
                //     ),
                //     title: Text(
                //       'Manager',
                //       style: TextStyle(
                //         color: Colors.black,
                //       ),
                //     ),
                //   ),
                // ),
                containerChild(
                  ListTile(
                    onTap: () async {
                      final hasAuth = await _biometrikController.authReuired();
                      if (hasAuth) {
                        autentikasiAktif.value = !autentikasiAktif.value;
                        saveSettingsPrefs();
                      }
                    },
                    leading: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    trailing: Obx(() => Checkbox(
                          activeColor: Colors.black,
                          checkColor: Colors.white,
                          value: autentikasiAktif.value,
                          onChanged: (value) async {
                            final hasAuth =
                                await _biometrikController.authReuired();
                            if (hasAuth) {
                              autentikasiAktif.value = value ?? false;
                              saveSettingsPrefs();
                            }
                          },
                        )),
                    title: Text(
                      'Autentikasi',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                containerChild(ListTile(
                  onTap: () {
                    PrintingQR(dariBox: false.obs).dialogQR();
                  },
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Simpan QRCode',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )),
                containerChild(
                  InkWell(
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.blue)),
                          title: Text(
                            'Konfirmasi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          alignment: Alignment.center,
                          content: Text(
                              'Keluar dari akun ${_splashController.username.value}?'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('Batal')),
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  _splashController.box.remove('token');
                                  _splashController.box.remove('username');
                                  Get.offAll(SplashLogin());
                                },
                                child: Text('Keluar')),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: Get.width * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Keluar",
                          style: TextStyle(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 255, 29, 13)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> saveSettingsPrefs() async {
    storage.write('autentikasiAktif', autentikasiAktif.value);
  }

  static Future<void> loadSettingsPrefs() async {
    autentikasiAktif.value = storage.read('autentikasiAktif') ?? false;
  }

  Column containerChild(Widget child) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.blue)],
              color: Colors.white),
          child: child,
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
