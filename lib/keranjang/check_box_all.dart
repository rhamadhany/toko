import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/keranjang_controller.dart';

class CheckBoxAll extends StatelessWidget {
  const CheckBoxAll({super.key});
  static final KeranjangController _keranjangController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Card(
        child: InkWell(
          onTap: () {
            _keranjangController.boxAll.value =
                !_keranjangController.boxAll.value;
            CheckBoxAll.selectall();
          },
          child: Row(
            children: [
              Checkbox(
                  value: _keranjangController.boxAll.value,
                  onChanged: (value) {
                    _keranjangController.boxAll.value = value ?? false;
                    selectall();
                  }),
              const Spacer(),
              const Text(
                "Pilih Semua",
                style: TextStyle(fontSize: 18),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    });
  }

  static void selectall() {
    final value = _keranjangController.boxAll.value;
    if (value == true) {
      for (int i = 0; i < _keranjangController.valueBox.length; i++) {
        _keranjangController.valueBox[i] = true;
      }
    } else {
      for (int i = 0; i < _keranjangController.valueBox.length; i++) {
        _keranjangController.valueBox[i] = false;
      }
    }
  }
}
