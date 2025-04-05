import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';

class PopMenuLaporan extends GetView<LaporanController> {
  const PopMenuLaporan({super.key});

  TextStyle textStyle() {
    return TextStyle(fontWeight: FontWeight.bold);
  }

  PopupMenuItem pop(Widget widget) {
    return PopupMenuItem(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: widget,
      ),
    );
  }

  Icon? trailing(String title) {
    return controller.viewMode.value == title ? Icon(Icons.check) : null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showMenu(
              context: context,
              position: RelativeRect.fromLTRB(100, 75, 0, 0),
              items: [
                pop(Obx(() {
                  return ExpansionTile(
                    showTrailingIcon: false,
                    title: Text(
                      'Laporan',
                      style: textStyle(),
                    ),
                    leading: Icon(Icons.expand),
                    children: [
                      pop(
                        ListTile(
                          trailing: trailing('Tahun'),
                          onTap: () {
                            controller.viewMode.value = 'Tahun';
                          },
                          title: Text(
                            'Tahunan',
                            style: textStyle(),
                          ),
                          leading: Icon(
                            Icons.today,
                          ),
                        ),
                      ),
                      pop(
                        ListTile(
                          trailing: trailing('Bulan'),
                          onTap: () {
                            controller.viewMode.value = 'Bulan';
                          },
                          title: Text(
                            'Bulanan',
                            style: textStyle(),
                          ),
                          leading: Icon(
                            Icons.date_range,
                          ),
                        ),
                      ),
                      pop(
                        ListTile(
                          trailing: trailing('Hari'),
                          onTap: () {
                            controller.viewMode.value = 'Hari';
                          },
                          title: Text(
                            'Harian',
                            style: textStyle(),
                          ),
                          leading: Icon(
                            Icons.access_time,
                          ),
                        ),
                      ),
                      if (controller.tabIndex.value == 1)
                        pop(
                          ListTile(
                            trailing: trailing('Transaksi'),
                            onTap: () {
                              controller.viewMode.value = 'Transaksi';
                            },
                            title: Text(
                              'Transaksi',
                              style: textStyle(),
                            ),
                            leading: Icon(
                              Icons.money,
                            ),
                          ),
                        ),
                      pop(
                        ListTile(
                          trailing: trailing('Rincian'),
                          onTap: () {
                            controller.viewMode.value = 'Rincian';
                          },
                          title: Text(
                            'Rincian',
                            style: textStyle(),
                          ),
                          leading: Icon(
                            Icons.details,
                          ),
                        ),
                      ),
                    ],
                  );
                })),
                pop(ListTile(
                  onTap: () {
                    Get.back();
                    controller.oldScaleTransformTable.value =
                        controller.scaleTransformTable.value;
                    controller.showSliderScaler.value =
                        !controller.showSliderScaler.value;
                  },
                  title: Text(
                    'Zoom',
                    style: textStyle(),
                  ),
                  leading: Icon(Icons.zoom_in),
                ))
              ]);
        },
        icon: Icon(Icons.more_vert));
  }
}
