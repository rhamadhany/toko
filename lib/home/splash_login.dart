import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/splash_controller.dart';

class SplashLogin extends GetView<SplashController> {
  const SplashLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
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
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person_pin,
                                    color: Colors.white,
                                    size: 100,
                                  ),
                                  Text(
                                    'User Login',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.text,
                              controller: controller.usernameController,
                              decoration: InputDecoration(
                                  hintText: 'Username',
                                  hintStyle: TextStyle(color: Colors.black54),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white))),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                              height: 50, child: TextFormPassword(null)),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
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
          ));
    });
  }
}

class TextFormPassword extends GetView<SplashController> {
  const TextFormPassword(this.onTap, {super.key});

  final Function(String)? onTap;
  @override
  Widget build(BuildContext context) {
    controller.passwordController.text = '';
    return Obx(() {
      return TextFormField(
        obscureText: controller.passwordTersembunyi.value,
        keyboardType: TextInputType.visiblePassword,
        controller: controller.passwordController,
        style: TextStyle(color: Colors.black),
        onFieldSubmitted: (value) {
          // if (onTap != null) {
          onTap?.call(value);
          // }
        },
        decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                  color: Colors.black,
                  onPressed: () {
                    controller.passwordTersembunyi.value =
                        !controller.passwordTersembunyi.value;
                  },
                  icon: Icon(controller.passwordTersembunyi.value
                      ? Icons.visibility
                      : Icons.visibility_off)),
            ),
            hintText: 'Password',
            hintStyle: TextStyle(color: Colors.black54),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white))),
      );
    });
  }
}
