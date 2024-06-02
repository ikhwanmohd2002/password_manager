import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/model/password.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:http/http.dart' as http;

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  CurrentUser currentUser = Get.put(CurrentUser());

  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var urlController = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs;
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  addPassword() async {
    Password passwordModel = Password(
      password_id: 1,
      user_id: currentUser.user.user_id,
      password_title: titleController.text.trim(),
      website_url: urlController.text.trim(),
      password_content: passwordController.text.trim(),
    );

    try {
      var res = await http.post(Uri.parse(API.addPassword),
          body: passwordModel.toJson());

      if (res.statusCode == 200) {
        var resBodyOfSignUp = await jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(msg: "Added password");
          setState(() {
            titleController.clear();
            urlController.clear();
            passwordController.clear();
          });
          Future.delayed(const Duration(milliseconds: 2000), () {
            Get.to(DashboardOfFragments());
          });
        } else {
          Fluttertoast.showToast(msg: "An error has occured, try again");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text("Add Password"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: primary1Color))),
                              child: TextFormField(
                                controller: titleController,
                                validator: (value) =>
                                    value == "" ? "Please enter title" : null,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Title",
                                    hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: primary1Color))),
                              child: TextFormField(
                                controller: urlController,
                                validator: (value) {
                                  if (value == "") {
                                    return "Please enter website url";
                                  } else if (!Uri.parse(urlController.text)
                                      .isAbsolute) {
                                    return "Please enter valid website url";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        "Website URL eg. https://www.google.com/",
                                    hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Obx(
                                () => TextFormField(
                                  controller: passwordController,
                                  obscureText: isObsecure.value,
                                  onChanged: (value) {
                                    passNotifier.value =
                                        PasswordStrength.calculate(text: value);
                                  },
                                  validator: (value) {
                                    if (value == "") {
                                      return "Please enter password";
                                    }
                                    if (PasswordStrength.calculate(
                                            text: value!) ==
                                        PasswordStrength.weak) {
                                      return "Please enter at least medium password";
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
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: PasswordStrengthChecker(
                      strength: passNotifier,
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        PasswordStrength.instructions,
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
                            addPassword();
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
                              "Save",
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
