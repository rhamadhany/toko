import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/data_settings.dart';
import 'package:myapp/pengaturan/printing_qr.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static final autentikasiAktif = false.obs;
  static final BiometrikController _biometrikController = Get.find();
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
