import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/biometrik.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                child: InkWell(
                  onTap: () async {
                    final hasAuth = await _biometrikController.authReuired();
                    if (hasAuth) {
                      autentikasiAktif.value = !autentikasiAktif.value;
                      saveSettingsPrefs();
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.lock),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktifkan Auntentikasi",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                          value: autentikasiAktif.value,
                          onChanged: (value) async {
                            final hasAuth =
                                await _biometrikController.authReuired();
                            if (hasAuth) {
                              autentikasiAktif.value = value ?? false;
                              saveSettingsPrefs();
                            }
                          })
                    ],
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
