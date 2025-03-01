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
        title: Row(
          children: [
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Get.back();
              },
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextField(
          controller: _productController.listTextField[5]['controller'],
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.top,
          expands: true,
          maxLines: null,
          decoration: const InputDecoration(
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            border: OutlineInputBorder(borderSide: BorderSide()),
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
