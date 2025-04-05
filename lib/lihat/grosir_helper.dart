import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/controller/db_helper.dart';
import 'package:myapp/controller/splash_controller.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';

mixin GrosirHelper on DialogJualHelper {
  final kodeDiskon = generateKode();
  Future<void> addListGrosir() async {
    final map = {
      'nama': DialogJualHelper.controllerNamaGrosir['controller'].text,
      'min_produk':
          DialogJualHelper.controllerJumlahMinPotonganHarga['controller'].text,
      'diskon': DialogJualHelper.controllerPotonganHarga['controller'].text,
      'kode_diskon': kodeDiskon,
    };
    final json = jsonEncode([map]);
    final url = Uri.parse("$domain/tambah");
    await http.post(url, body: {'tabel': 'diskon', 'produk': json});
    loadListGrosir();
  }

  Future<void> loadListGrosir() async {
    final url = Uri.parse("$domain/load");
    final response = await http.post(url, body: {
      'tabel': 'diskon',
    });
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      json.insert(0, defaultSelectedGrosir);
      DialogJualHelper.listGrosir.value = List<Map<String, dynamic>>.from(json);
      DialogJualHelper.listGrosir.refresh();
      // print(listGrosir);
    }
    if (DialogJualHelper.selectedGrosir.isEmpty) {
      DialogJualHelper.selectedGrosir.value = defaultSelectedGrosir;
    }
  }

  Future<void> updateGrosir(String kode) async {
    final map = {
      'nama': DialogJualHelper.controllerNamaGrosir['controller'].text,
      'min_produk':
          DialogJualHelper.controllerJumlahMinPotonganHarga['controller'].text,
      'diskon': DialogJualHelper.controllerPotonganHarga['controller'].text,
      'kode_diskon': kode,
    };
    final json = jsonEncode(map);
    final url = Uri.parse("$domain/update_grosir");
    await http.post(url, body: {"grosir": json});
    loadListGrosir();
  }

  Future<void> removeListGrosir(String kode) async {
    final url = Uri.parse('$domain/delete');
    await http.post(url, body: {
      'tabel': 'diskon',
      'list_kode': jsonEncode([kode])
    });
    loadListGrosir();
  }
}
