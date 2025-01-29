import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/permission_request.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pick_or_save/pick_or_save.dart';
import 'package:restart_app/restart_app.dart';

class DataSettings {
  static final progress = ''.obs;
  static final progressFinish = false.obs;

  static importData() async {
    await PermissionRequest.periksaIzin();
    if (!PermissionRequest.dapatIzin.value) {
      return;
    }
    progressFinish.value = false;
    List<String>? result = await PickOrSave().filePicker(
      params: FilePickerParams(
          getCachedFilePath: false, allowedExtensions: ['.zip']),
    );
    if (result != null && result.isNotEmpty) {
      Get.dialog(barrierDismissible: false, dialogLoading('Import Data', true));
      String uri = result[0];
      final uriDecode = Uri.decodeFull(uri);

      final convertUri = convertContentUri(uriDecode);
      final filename = convertUri.split('/').last;
      progress.value = 'Import data dari $filename';

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final packageName = packageInfo.packageName;
      final output = '/data/user/0/$packageName/';

      extractFileToDisk(convertUri, output);
      progressFinish.value = true;
      progress.value = '$filename berhasil di import';
    }
  }

  static String convertContentUri(String uri) {
    final regex = RegExp(r'content://.*?:(.*)');

    final match = regex.firstMatch(uri);

    if (match != null) {
      final path = match.group(1);

      return '/storage/emulated/0/$path';
    } else {
      return '';
    }
  }

  static Future<void> backupData() async {
    await PermissionRequest.periksaIzin();
    if (!PermissionRequest.dapatIzin.value) {
      return;
    }

    final output = await outputFile();
    final tempDir = await getTemporaryDirectory();

    final slitPath = tempDir.path.split('/');
    final sub = slitPath.last;
    final path = tempDir.path.replaceAll(sub, "");
    final gambar = '${path}cache';
    final database = '${path}databases';

    if (output != null) {
      progressFinish.value = false;
      final encoder = ZipFileEncoder();

      try {
        Get.dialog(
            barrierDismissible: false, dialogLoading('Backup Data', false));

        encoder.create(output);

        progress.value = "Menyimpan gambar ke $output";
        await encoder.addDirectory(Directory(gambar));
        progress.value = "Menyimpan database ke $output";
        await encoder.addDirectory(Directory(database));
        encoder.closeSync();
        progress.value = 'Data telah disimpan ke $output';
        progressFinish.value = true;
      } catch (e) {
        // print(e);
        Get.snackbar("Error", '$e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  static Widget dialogLoading(String title, bool isImport) {
    return Obx(() {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: Get.height * 0.15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!progressFinish.value)
                        const LinearProgressIndicator(color: Colors.blue),
                      if (!progressFinish.value) const SizedBox(height: 30),
                      Text(progress.value),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (progressFinish.value && !isImport)
            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Ok"),
            ),
          if (progressFinish.value && isImport)
            ElevatedButton(
                onPressed: () {
                  Restart.restartApp();
                },
                child: const Text("Restart"))
        ],
      );
    });
  }

  static Future<String?> outputFile() async {
    try {
      final rootPath = await getExternalStorageDirectory();
      if (rootPath != null) {
        final split = rootPath.path.split('/');
        final sdcard = '/${split[1]}/${split[2]}/${split[3]}/Toko';

        final backupDir = Directory(sdcard);
        if (!backupDir.existsSync()) {
          Directory(sdcard).createSync();
        }

        final date =
            DateTime.now().toString().replaceAll(" ", "_").replaceAll(":", ".");
        return '$sdcard/Backup_$date.zip'.replaceAll("'", '');
      }
    } catch (e) {
      Get.snackbar("Error", "Backup $e", snackPosition: SnackPosition.BOTTOM);
      return null;
    }
    return null;
  }
}
