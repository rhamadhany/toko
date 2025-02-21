import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/home/splash_login.dart';
import 'package:myapp/manager/manager_toko.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/data_settings.dart';
import 'package:myapp/pengaturan/printing_qr.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static final autentikasiAktif = false.obs;
  static final BiometrikController _biometrikController = Get.find();
  static final SplashController _splashController = Get.find();
  static final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        onTap: () async {
                          final hasAuth =
                              await _biometrikController.authReuired();
                          if (hasAuth) {
                            autentikasiAktif.value = !autentikasiAktif.value;
                            saveSettingsPrefs();
                          }
                        },
                        title: const Text("Aktifkan Autentikasi"),
                        leading: Icon(
                          autentikasiAktif.value ? Icons.lock : Icons.lock_open,
                        ),
                      ),
                    ),
                    Checkbox(
                      activeColor: Colors.blue,
                      value: autentikasiAktif.value,
                      onChanged: (value) async {
                        final hasAuth =
                            await _biometrikController.authReuired();
                        if (hasAuth) {
                          autentikasiAktif.value = value ?? false;
                          saveSettingsPrefs();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: const Text("Import Data"),
                  leading: const Icon(Icons.download),
                  onTap: () {
                    DataSettings.importData();
                  },
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: const Text("Backup Data"),
                  leading: const Icon(Icons.backup),
                  onTap: () {
                    DataSettings.backupData();
                  },
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: const Text("Simpan QRCode"),
                  leading: const Icon(Icons.picture_as_pdf),
                  onTap: () {
                    // DataSettings.backupData();
                    PrintingQR(dariBox: false.obs).dialogQR();
                  },
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: const Text("Manager"),
                  leading: const Icon(Icons.warehouse),
                  onTap: () {
                    Get.put(ManagerController());
                    Get.to(() => ManagerToko());
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      'Konfirmasi',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
              ),
            ),
          ],
        ),
      );
    });
  }

  static Future<void> saveSettingsPrefs() async {
    storage.write('autentikasiAktif', autentikasiAktif.value);
  }

  static Future<void> loadSettingsPrefs() async {
    autentikasiAktif.value = storage.read('autentikasiAktif') ?? false;
  }
}
