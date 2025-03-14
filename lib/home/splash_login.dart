import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';

class SplashLogin extends GetView<SplashController> {
  const SplashLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Material(
          child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.purple[400]!])),
        child: controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Center(
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: SizedBox(
                                  height: 50,
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    keyboardType: TextInputType.text,
                                    controller: controller.usernameController,
                                    decoration: InputDecoration(
                                        hintText: 'Username',
                                        hintStyle:
                                            TextStyle(color: Colors.black54),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Colors.white))),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: SizedBox(
                                  height: 50,
                                  child: TextFormField(
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
                                                controller.passwordTersembunyi
                                                        .value =
                                                    !controller
                                                        .passwordTersembunyi
                                                        .value;
                                              },
                                              icon: Icon(controller
                                                      .passwordTersembunyi.value
                                                  ? Icons.visibility
                                                  : Icons.visibility_off)),
                                        ),
                                        hintText: 'Password',
                                        hintStyle:
                                            TextStyle(color: Colors.black54),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Colors.white))),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        backgroundColor: Colors.black),
                                    onPressed: () async {
                                      await controller.loginUser();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Sign in',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ));
    });
  }
}
