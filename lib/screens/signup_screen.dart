import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var formKey = GlobalKey<FormState>();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController1 = TextEditingController();
  var passwordController2 = TextEditingController();
  var isObsecure = true.obs;
  var isObsecure2 = true.obs;

  final passNotifier = ValueNotifier<PasswordStrength?>(null);
  final passNotifier1 = ValueNotifier<CustomPassStrength?>(null);

  validateUserEmail() async {
    try {
      var res = await http.post(Uri.parse(API.validateEmail),
          body: {'user_email': emailController.text.trim()});

      if (res.statusCode == 200) {
        var resBodyOfValidateEmail = jsonDecode(res.body);
        if (resBodyOfValidateEmail['emailFound'] == true) {
          Fluttertoast.showToast(
              msg: "Email already in use. Try another email.");
        } else {
          registerAndSaveUserRecord();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveUserRecord() async {
    User userModel = User(
      1,
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController1.text.trim(),
    );

    try {
      var res =
          await http.post(Uri.parse(API.signUp), body: userModel.toJson());

      if (res.statusCode == 200) {
        var resBodyOfSignUp = await jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(msg: "You have successfully registered");
          setState(() {
            usernameController.clear();
            emailController.clear();
            passwordController1.clear();
          });
          Future.delayed(const Duration(milliseconds: 2000), () {
            Get.to(const LoginScreen());
          });
        } else {
          Fluttertoast.showToast(msg: "An error has occured, try again");
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
                height: 150,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 150,
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
                      top: 10,
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
                                "Register",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    controller: usernameController,
                                    validator: (value) => value == ""
                                        ? "Please write username"
                                        : null,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Username",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[700])),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: primary1Color))),
                                  child: TextFormField(
                                    controller: emailController,
                                    validator: (value) {
                                      if (value == "") {
                                        return "Please write email";
                                      } else if (EmailValidator.validate(
                                              value!) ==
                                          false) {
                                        return "Please write valid email";
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[700])),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: primary1Color))),
                                  child: Obx(
                                    () => TextFormField(
                                      controller: passwordController1,
                                      obscureText: isObsecure.value,
                                      onChanged: (value) {
                                        passNotifier1.value =
                                            CustomPassStrength.calculate(
                                                text: value);
                                      },
                                      validator: (value) {
                                        if (value == "") {
                                          return "Please enter password";
                                        } else if (CustomPassStrength.calculate(
                                                text: value!) ==
                                            CustomPassStrength.weak) {
                                          return "Please enter at least strong password";
                                        } else if (CustomPassStrength.calculate(
                                                text: value) ==
                                            CustomPassStrength.medium) {
                                          return "Please enter at least strong password";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                          suffixIcon: Obx(() => GestureDetector(
                                                onTap: () {
                                                  isObsecure.value =
                                                      !isObsecure.value;
                                                },
                                                child: Icon(
                                                  isObsecure.value
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.black,
                                                ),
                                              )),
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle: TextStyle(
                                              color: Colors.grey[700])),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Obx(
                                    () => TextFormField(
                                      controller: passwordController2,
                                      obscureText: isObsecure2.value,
                                      validator: (value) {
                                        if (value == "" ||
                                            value !=
                                                passwordController1.text
                                                    .trim()) {
                                          return "Please reenter password";
                                        }
                                      },
                                      decoration: InputDecoration(
                                          suffixIcon: Obx(() => GestureDetector(
                                                onTap: () {
                                                  isObsecure2.value =
                                                      !isObsecure2.value;
                                                },
                                                child: Icon(
                                                  isObsecure2.value
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.black,
                                                ),
                                              )),
                                          border: InputBorder.none,
                                          hintText: "Confirm Password",
                                          hintStyle: TextStyle(
                                              color: Colors.grey[700])),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: PasswordStrengthChecker(
                        strength: passNotifier1,
                      ),
                    ),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          CustomPassStrength.instructions,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1900),
                        child: InkWell(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              validateUserEmail();
                            }
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  primary2Color,
                                  primary1Color,
                                ])),
                            child: const Center(
                              child: Text(
                                "Register Account",
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
                            Get.to(const LoginScreen());
                          },
                          child: Center(
                            child: Text(
                              "Have an account?",
                              style: TextStyle(color: primary1Color),
                            ),
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
