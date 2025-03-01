// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myapp/pengaturan/settings.dart';

class BiometrikController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  final canAuthenticateWithBiometrics = false.obs;
  final canAuthenticate = false.obs;
  List<BiometricType>? availableBiometrics;

  final hasAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    Settings.loadSettingsPrefs();
  }

  Future<void> initBeometrik() async {
    availableBiometrics = await auth.getAvailableBiometrics();
    final devicesSupport = await auth.isDeviceSupported();

    canAuthenticateWithBiometrics.value = await auth.canCheckBiometrics;

    canAuthenticate.value =
        canAuthenticateWithBiometrics.value || devicesSupport;
  }

  Future<bool> authReuired() async {
    try {
      await initBeometrik();
      return await auth.authenticate(
          localizedReason: 'Autentikasi diperlukan untuk menampilkan menu ini!',
          options: const AuthenticationOptions(useErrorDialogs: false));
    } catch (e) {
      // Get.snackbar("Error", "$e", snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
      if (!e.toString().toLowerCase().contains('progress')) {
        Settings.autentikasiAktif.value = false;
        Settings.saveSettingsPrefs();
      }

      return false;
    }
  }
}
