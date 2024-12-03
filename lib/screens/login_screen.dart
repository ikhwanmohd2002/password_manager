import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
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
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  int attempt = 0;
  int hour = DateTime.now().hour;
  double? currentLat;
  double? currentLon;

  double calculateDistanceVariance(
      double lat1, double lon1, double lat2, double lon2) {
    double distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    distance /= 1000;

    return distance;
  }

  loginUserNow() async {
    int? locationVariance;
    List<double>? prevLocation = await RememberUserPrefs.readLocation();
    if (prevLocation != null) {
      var doubleVar = calculateDistanceVariance(
          prevLocation[0], prevLocation[1], currentLat!, currentLon!);
      locationVariance = doubleVar.round();
    }
    try {
      var res = await http.post(Uri.parse(API.loginIntelliVault), body: {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim()
      });

      if (res.statusCode == 200) {
        var resBodyOfLogin = jsonDecode(res.body);

        String token = resBodyOfLogin['key'];
        var res1 = await http.get(
          Uri.parse(API.userDetailsIntelliVault),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          },
        );
        var resBodyOfUserDetails = jsonDecode(res1.body);
        int pk = resBodyOfUserDetails['pk'];
        User userInfo = User(pk, usernameController.text.trim(),
            emailController.text.trim(), '', '');
        RememberUserPrefs.storeUserInfo(userInfo);
        RememberUserPrefs.storeToken(token);
        RememberUserPrefs.removeLocation();
        RememberUserPrefs.storeLocation(currentLat!, currentLon!);

        bool? checkLogin =
            await predictLoginAttempt(hour, attempt, locationVariance!);

        if (checkLogin != null) {
          if (checkLogin == false) {
            Fluttertoast.showToast(msg: "Login Anomalous");
          } else {
            Fluttertoast.showToast(msg: "Successfully logged in");
            Future.delayed(Duration(milliseconds: 2000), () {
              Get.to(DashboardOfFragments());
            });
          }
        }
      } else {
        setState(() {
          attempt++;
        });
        Fluttertoast.showToast(msg: "Failed to login. Please Try Again");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to login. Please Try Again!!");
      print(e.toString());
    }
  }

  Future<void> _getLocation() async {
    RememberUserPrefs locationService = RememberUserPrefs();
    try {
      Position position = await locationService.getCurrentLocation();
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      setState(() {
        currentLat = position.latitude;
        currentLon = position.longitude;
      });
    } catch (e) {}
  }

  Future<bool?> predictLoginAttempt(int time, int attempt, int variance) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(Uri.parse(API.predictLoginIntelliVault),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "time": time,
            "attempt": attempt,
            "location": variance,
          }));

      if (res.statusCode == 200) {
        var responseBodyOfPredictLogin = jsonDecode(res.body);
        String prediction = responseBodyOfPredictLogin["prediction"];
        if (prediction == "anomalous") {
          return false;
        } else {
          return true;
        }
      } else {
        Fluttertoast.showToast(msg: "Error predicting login");
        return null;
      }
    } catch (errorMsg) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
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
                                        ? "Please write password"
                                        : null,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
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
              ),
              // Form(
              //   key: formKey1,
              //   child: Column(
              //     children: <Widget>[
              //       Container(
              //         padding: const EdgeInsets.all(8.0),
              //         decoration: BoxDecoration(
              //             border:
              //                 Border(bottom: BorderSide(color: primary1Color))),
              //         child: TextFormField(
              //           controller: nameController1,
              //           validator: (value) =>
              //               value == "" ? "Please write name" : null,
              //           decoration: InputDecoration(
              //               border: InputBorder.none,
              //               hintText: "Name",
              //               hintStyle: TextStyle(color: Colors.grey[700])),
              //         ),
              //       ),
              //       Container(
              //         padding: const EdgeInsets.all(8.0),
              //         decoration: BoxDecoration(
              //             border:
              //                 Border(bottom: BorderSide(color: primary1Color))),
              //         child: TextFormField(
              //           controller: emailController1,
              //           validator: (value) =>
              //               value == "" ? "Please write email" : null,
              //           decoration: InputDecoration(
              //               border: InputBorder.none,
              //               hintText: "Email",
              //               hintStyle: TextStyle(color: Colors.grey[700])),
              //         ),
              //       ),
              //       Container(
              //         padding: const EdgeInsets.all(8.0),
              //         child: TextFormField(
              //           controller: passwordController1,
              //           obscureText: true,
              //           validator: (value) =>
              //               value == "" ? "Please write master password" : null,
              //           decoration: InputDecoration(
              //               border: InputBorder.none,
              //               hintText: "Master Password",
              //               hintStyle: TextStyle(color: Colors.grey[700])),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // InkWell(
              //   onTap: () {
              //     if (formKey1.currentState!.validate()) {
              //       testAPI();
              //     }
              //   },
              //   child: Container(
              //     height: 50,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(10),
              //         gradient: LinearGradient(colors: [
              //           primary2Color,
              //           primary1Color,
              //         ])),
              //     child: const Center(
              //       child: Text(
              //         "Test API",
              //         style: TextStyle(
              //             color: Colors.white, fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ));
  }
}
