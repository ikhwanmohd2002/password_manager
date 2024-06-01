import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/model/user.dart';
import 'package:password_manager/screens/signup_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  loginUserNow() async {
    try {
      var res = await http.post(Uri.parse(API.login), body: {
        'user_email': emailController.text.trim(),
        'user_master_password': passwordController.text.trim()
      });

      if (res.statusCode == 200) {
        var resBodyOfLogin = jsonDecode(res.body);
        if (resBodyOfLogin['success'] == true) {
          Fluttertoast.showToast(msg: "Successfully logged in");
          User userInfo = User.fromJson(resBodyOfLogin["userData"]);

          await RememberUserPrefs.storeUserInfo(userInfo);
          Future.delayed(const Duration(milliseconds: 2000), () {
            Get.to(DashboardOfFragments());
          });
        } else {
          Fluttertoast.showToast(msg: "Failed to login. Please Try Again");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeInUp(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('images/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('images/light-2.png'))),
                          )),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('images/clock.png'))),
                          )),
                    ),
                    Positioned(
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: primary1Color),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: primary1Color))),
                                  child: TextFormField(
                                    controller: emailController,
                                    validator: (value) => value == ""
                                        ? "Please write email"
                                        : null,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[700])),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: passwordController,
                                    obscureText: true,
                                    validator: (value) => value == ""
                                        ? "Please write master password"
                                        : null,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Master Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[700])),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1900),
                        child: InkWell(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              loginUserNow();
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  primary2Color,
                                  primary1Color,
                                ])),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 2000),
                        child: InkWell(
                          onTap: () {
                            Get.to(const SignUpScreen());
                          },
                          child: Text(
                            "Dont have an account?",
                            style: TextStyle(color: primary1Color),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
