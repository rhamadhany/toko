import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';

class SplashLogin extends GetView<SplashController> {
  const SplashLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          body: controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : Container(
                  height: Get.height,
                  width: Get.width,
                  decoration: BoxDecoration(color: Colors.blue
                      // gradient: LinearGradient(colors: [
                      // const Color.fromARGB(255, 159, 0, 187),
                      // Colors.blue,
                      // ])
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: Get.height * 0.5,
                          decoration: BoxDecoration(
                              color: Colors.black.withAlpha(99),
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                style: TextStyle(color: Colors.black),
                                keyboardType: TextInputType.text,
                                controller: controller.usernameController,
                                decoration: InputDecoration(
                                    hintText: 'Username',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                obscureText:
                                    controller.passwordTersembunyi.value,
                                keyboardType: TextInputType.visiblePassword,
                                controller: controller.passwordController,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    suffixIcon: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IconButton(
                                          color: Colors.black,
                                          onPressed: () {
                                            controller
                                                    .passwordTersembunyi.value =
                                                !controller
                                                    .passwordTersembunyi.value;
                                          },
                                          icon: Icon(controller
                                                  .passwordTersembunyi.value
                                              ? Icons.visibility
                                              : Icons.visibility_off)),
                                    ),
                                    hintText: 'Password',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                  onPressed: () async {
                                    await controller.loginUser();
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )));
    });
  }
}
