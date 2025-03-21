import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';

import 'package:myapp/lihat/grosir_helper.dart';

class InputDiskonHarga extends StatelessWidget
    with DialogJualHelper, GrosirHelper {
  InputDiskonHarga({
    super.key,
    this.kode = '',
  });
  // final bool isEditing;
  final String kode;
  @override
  Widget build(BuildContext context) {
    final listW = [
      DialogJualHelper.controllerNamaGrosir,
      DialogJualHelper.controllerJumlahMinPotonganHarga,
      DialogJualHelper.controllerPotonganHarga
    ];
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue)),
      content: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: Get.height * 0.5, maxWidth: Get.width * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(listW.length, (i) {
              {
                return TextField(
                  controller: listW[i]['controller'],
                  decoration: InputDecoration(
                      labelText: listW[i]['label'],
                      prefixText: i == 2 ? 'Rp ' : ''),
                  keyboardType:
                      i == 0 ? TextInputType.text : TextInputType.number,
                  inputFormatters: [
                    if (i != 0)
                      FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  onChanged: (value) {},
                );
              }
            })
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back();
              if (kode != '') {
                updateGrosir(kode);
              } else {
                addListGrosir();
              }
            },
            child: Text('Oke'))
      ],
    );
  }
}
