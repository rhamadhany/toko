import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/product_controller.dart';

class EditDeskripsi extends StatelessWidget {
  EditDeskripsi({super.key});
  final ProductController _productController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Deskripsi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _productController.listTextField[5]['controller'],
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.top,
          expands: true,
          maxLines: null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            // label: Text(
            //   _productController.listTextField[5]['label'],
            // ),
            // hintText: _productController.listTextField[5]['label'],
          ),
          onChanged: (_) {
            _productController.listTextField.refresh();
          },
        ),
      ),
    );
  }
}
