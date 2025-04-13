import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/manager/drawer_admin.dart';
import 'package:myapp/manager/manager_controller.dart';

class MenuManager extends GetView<ManagerController> {
  const MenuManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.deepPurple, Colors.purple])),
            child: DrawerAdmin()));
  }
}
