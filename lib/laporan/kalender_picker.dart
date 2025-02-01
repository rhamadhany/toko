import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/laporan_controller.dart';

class KalenderPicker extends StatelessWidget {
  KalenderPicker({super.key});
  final LaporanController _laporanController = Get.find();
  final daftarBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ].obs;
  final daftarTahun = [].obs;
  final tahunTertinggi = 0.obs;
  final tahunTerendah = 0.obs;
  final tampilkandaftarTahun = false.obs;
  // final daftarBulan = ['Januari', 'Februari', 'Maret', 'April',]
  @override
  Widget build(BuildContext context) {
    // print(_laporanController.bulanIni);
    nilaitahun();
    return Obx(() {
      return Dialog(
        child: SizedBox(
          // padding: const EdgeInsets.all(16),
          height: Get.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // ubah ini
            crossAxisAlignment: CrossAxisAlignment.center, // tambahkan ini

            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _laporanController.bulanTerpilih.value,
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          _laporanController.tahunTerpilih.value.toString(),
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              int currentIndex = daftarTahun.indexOf(
                                  _laporanController.tahunTerpilih.value
                                      .toString());
                              // print(currentIndex);
                              if (currentIndex > 0) {
                                _laporanController.tahunTerpilih.value =
                                    int.tryParse(
                                            daftarTahun[currentIndex - 1]) ??
                                        _laporanController.tahunTerpilih.value;
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_left,
                              color: Colors.white,
                            )),
                        TextButton(
                          onPressed: () {
                            tampilkandaftarTahun.value =
                                !tampilkandaftarTahun.value;
                          },
                          child: Text(
                            _laporanController.tahunTerpilih.value.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              int currentIndex = daftarTahun.indexOf(
                                  _laporanController.tahunTerpilih.value
                                      .toString());
                              // print(currentIndex);
                              if (currentIndex < daftarTahun.length - 1) {
                                _laporanController.tahunTerpilih.value =
                                    int.tryParse(
                                            daftarTahun[currentIndex + 1]) ??
                                        _laporanController.tahunTerpilih.value;
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_right,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                // Mengganti SizedBox dengan Expanded
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                      itemCount: tampilkandaftarTahun.value
                          ? daftarTahun.length
                          : daftarBulan.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) {
                        final bulan = _laporanController.bulanTerpilih.value;
                        final bulanTerpilih =
                            bulan.contains(daftarBulan[index]).obs;
                        final tahunSelect = index < daftarTahun.length
                            ? daftarTahun[index] ==
                                _laporanController.tahunTerpilih.value
                                    .toString()
                            : daftarTahun.toString() ==
                                _laporanController.tahunTerpilih.value
                                    .toString();
                        // print(daftarTahun[index]);
                        return Card(
                            color: tahunSelect && tampilkandaftarTahun.value
                                ? Colors.blue
                                : !tampilkandaftarTahun.value &&
                                        bulanTerpilih.value
                                    ? Colors.blue
                                    : null,
                            child: TextButton(
                                onPressed: () {
                                  if (tampilkandaftarTahun.value) {
                                    _laporanController.tahunTerpilih.value =
                                        int.tryParse(daftarTahun[index]) ??
                                            _laporanController
                                                .tahunTerpilih.value;
                                    tampilkandaftarTahun.value =
                                        !tampilkandaftarTahun.value;
                                  } else {
                                    _laporanController.bulanTerpilih.value =
                                        _laporanController.namaBulan[index];
                                    Get.back();
                                  }
                                },
                                child: Text(
                                  tampilkandaftarTahun.value
                                      ? daftarTahun[index]
                                      : daftarBulan[index],
                                  style: TextStyle(
                                    color: tahunSelect &&
                                            tampilkandaftarTahun.value
                                        ? Colors.white
                                        : !tampilkandaftarTahun.value &&
                                                bulanTerpilih.value
                                            ? Colors.white
                                            : null,
                                  ),
                                )));
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void nilaitahun() {
    final daftarTanggal = _laporanController.penjualan;
    daftarTahun.value = daftarTanggal
        .map((item) => item['tanggal'].split('-')[0])
        .toSet()
        .toList();
    daftarTahun.sort((a, b) {
      return a.compareTo(b);
    });
    // daftarTahun.value = tahun;
    final tertinggi =
        daftarTahun.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b);
    final terendah =
        daftarTahun.reduce((a, b) => int.parse(a) < int.parse(b) ? a : b);
    tahunTertinggi.value = int.parse(tertinggi);
    tahunTerendah.value = int.parse(terendah);

    // if (tertinggi) {
    //   return  ?? DateTime.now().year.toInt();
    // } else {
    // return int.tryParse(tahunTerendah) ?? DateTime.now().year.toInt();
    // }
  }
}
