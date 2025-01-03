// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
  var passwordController = TextEditingController();
  var password2Controller = TextEditingController();
  List<RxBool> isObsecure = [true.obs, true.obs];

  final passNotifier = ValueNotifier<PasswordStrength?>(null);
  final passNotifier1 = ValueNotifier<CustomPassStrength?>(null);

  registerAndSaveUserRecord() async {
    User userModel = User(
      1,
      usernameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      password2Controller.text.trim(),
    );

    try {
      var res = await http.post(Uri.parse(API.registerIntelliVault),
          body: userModel.toJson());

      if (res.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You have successfully registered"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          usernameController.clear();
          emailController.clear();
          passwordController.clear();
          password2Controller.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.offAll(const LoginScreen());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error registering account"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
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
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0D47A1), Color(0xff1976D2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Text(
                  "Set Up Your Secure Vault",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: usernameController,
                            validator: (value) =>
                                value == "" ? "Please enter username" : null,
                            decoration: InputDecoration(
                              labelText: "Username",
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == "") {
                                return "Please enter email";
                              } else if (!EmailValidator.validate(value!)) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            onChanged: (value) {
                              passNotifier1.value =
                                  CustomPassStrength.calculate(text: value);
                            },
                            validator: (value) {
                              if (value == "") {
                                return "Please enter password";
                              } else if (CustomPassStrength.calculate(
                                      text: value!) ==
                                  CustomPassStrength.weak) {
                                return "Password strength is weak";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: password2Controller,
                            obscureText: true,
                            validator: (value) {
                              if (value != passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          PasswordStrengthChecker(
                            strength: passNotifier1,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CustomPassStrength.instructions,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        registerAndSaveUserRecord();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: primary1Color,
                    ),
                    child: const Center(
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Get.to(const LoginScreen());
                    },
                    child: Center(
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: primary1Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
