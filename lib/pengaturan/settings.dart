import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/controller/biometrik.dart';
import 'package:myapp/pengaturan/printing_qr.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  static final autentikasiAktif = false.obs;
  static final BiometrikController _biometrikController = Get.find();
  static final storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  'BIOMETRIK',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
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
                'QRCODE',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            )),
          ],
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
