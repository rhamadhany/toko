import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/lihat/dialog_jual_helper.dart';
import 'package:myapp/lihat/grosir_helper.dart';
import 'package:myapp/lihat/input_diskon_harga.dart';

class DialogListGrosir extends StatelessWidget
    with DialogJualHelper, GrosirHelper {
  DialogListGrosir({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue)),
        content: Obx(() {
          // print(listGrosir);
          return ConstrainedBox(
              constraints: (BoxConstraints(maxHeight: Get.height * 0.5)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'GROSIR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                            onPressed: () {
                              Get.dialog(InputDiskonHarga());
                            },
                            icon: Icon(
                              Icons.add,
                              // color: Colors.white,
                            )),
                      ],
                    ),
                    if (DialogJualHelper.listGrosir.isEmpty)
                      Center(
                          child: Icon(
                        Icons.store,
                        size: Get.height * 0.25,
                        color: Colors.white,
                      )),
                    if (DialogJualHelper.listGrosir.isNotEmpty)
                      ...List.generate(DialogJualHelper.listGrosir.length, (i) {
                        final nama = DialogJualHelper.listGrosir[i]['nama'];
                        final minProduk = DialogJualHelper.listGrosir[i]
                                ['min_produk']
                            .toString();
                        final diskon =
                            DialogJualHelper.listGrosir[i]['diskon'].toString();
                        final kode =
                            DialogJualHelper.listGrosir[i]['kode_diskon'];
                        return Card(
                          color: DialogJualHelper
                                      .selectedGrosir['kode_diskon'] ==
                                  DialogJualHelper.listGrosir[i]['kode_diskon']
                              ? Colors.blue
                              : null,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            child: Slidable(
                              endActionPane:
                                  ActionPane(motion: ScrollMotion(), children: [
                                SlidableAction(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  onPressed: (_) {
                                    initController(kode);
                                    Get.dialog(InputDiskonHarga(
                                      kode: kode,
                                    ));
                                  },
                                ),
                                SlidableAction(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  onPressed: (_) {
                                    removeListGrosir(kode);
                                  },
                                )
                              ]),
                              child: ListTile(
                                onTap: () {
                                  Get.back();
                                  DialogJualHelper.selectedGrosir.value =
                                      DialogJualHelper.listGrosir[i];
                                  GetStorage().write('selectedGrosir',
                                      DialogJualHelper.selectedGrosir);
                                },
                                title: Text(
                                  nama,
                                  style: TextStyle(
                                    color: DialogJualHelper.selectedGrosir[
                                                'kode_diskon'] ==
                                            DialogJualHelper.listGrosir[i]
                                                ['kode_diskon']
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'Jumlah: $minProduk, Diskon: $diskon',
                                  style: TextStyle(
                                    color: DialogJualHelper.selectedGrosir[
                                                'kode_diskon'] ==
                                            DialogJualHelper.listGrosir[i]
                                                ['kode_diskon']
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      })
                  ],
                ),
              ));
        }));
  }
}
