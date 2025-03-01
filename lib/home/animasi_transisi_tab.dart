import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/main_controller.dart';

class AnimasiTransisiTab extends GetView<MainController> {
  const AnimasiTransisiTab(
      {required this.skalaAnimation, required this.widgetChild, super.key});
  final Widget widgetChild;
  final RxDouble skalaAnimation;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.tabController!.animation!,
      builder: (BuildContext context, Widget? child) {
        return Obx(() =>
            Transform.scale(scale: skalaAnimation.value, child: widgetChild));
      },
    );
  }
}
