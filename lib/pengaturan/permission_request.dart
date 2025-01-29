import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
  static final dapatIzin = false.obs;

  static Future<void> izinDenied() async {
    final sdkVersion = await versiSdk();

    if (sdkVersion <= 29) {
      await Permission.storage.request();
    } else {
      await Permission.manageExternalStorage.request();
    }
    periksaIzin();
  }

  static periksaIzin() async {
    final sdkVersion = await versiSdk();

    if (sdkVersion <= 29) {
      await sdk29();
    } else {
      await sdk30();
    }
  }

  static Future<void> sdk29() async {
    if (await Permission.storage.isDenied) {
      izinDenied();
    } else if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.isGranted) {
      dapatIzin.value = true;
    }
  }

  static Future<void> sdk30() async {
    if (await Permission.manageExternalStorage.isDenied) {
      izinDenied();
    } else if (await Permission.storage.isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.manageExternalStorage.isGranted) {
      dapatIzin.value = true;
    }
  }

  static Future<int> versiSdk() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }
}
