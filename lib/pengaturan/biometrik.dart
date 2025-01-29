import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myapp/pengaturan/settings.dart';

class BiometrikController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  final canAuthenticateWithBiometrics = false.obs;
  final canAuthenticate = false.obs;
  List<BiometricType>? availableBiometrics;
  // final lastIndexTabBar = 0.obs;
  final hasAuthenticated = false.obs;
  final tabIndex = 0.obs;
  // final indexBefore

  TabController? tabController;

  @override
  void onInit() {
    super.onInit();
    // initBeometrik();
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
      // hasAuthenticated.value = false;
      // print(e);
      Get.snackbar("Error", "$e", snackPosition: SnackPosition.BOTTOM);
      Settings.autentikasiAktif.value = false;
      Settings.saveSettingsPrefs();
      return false;
    }

    // if (!hasAuthenticated.value) {
    //   tabController?.animateTo(0);
    // } else {
    // tabIndex.value = tabController!.index;
    // }
  }
}
