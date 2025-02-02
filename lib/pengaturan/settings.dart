// import 'package:archive/archive_io.dart';
// import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/pengaturan/biometrik.dart';
import 'package:myapp/pengaturan/data_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:archive/archive_io.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static final autentikasiAktif = false.obs;
  static final BiometrikController _biometrikController = Get.find();
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
          ],
        ),
      );
    });
  }

  static Future<void> saveSettingsPrefs() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('autentikasiAktif', autentikasiAktif.value);
    });
  }

  static Future<void> loadSettingsPrefs() async {
    await SharedPreferences.getInstance().then((prefs) {
      autentikasiAktif.value = prefs.getBool("autentikasiAktif") ?? false;
    });
  }
}
