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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login Anomalous"),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Successfully logged in"),
                backgroundColor: Colors.green,
              ),
            );

            Future.delayed(Duration(milliseconds: 2000), () {
              Get.offAll(DashboardOfFragments(), arguments: {"logged": 0});
            });
          }
        }
      } else {
        setState(() {
          attempt++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to login. Please Try Again"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to login. Please Try Again!!"),
          backgroundColor: Colors.red,
        ),
      );
      print(e.toString());
    }
  }

  Future<void> _getLocation() async {
    RememberUserPrefs locationService = RememberUserPrefs();
    try {
      Position position = await locationService.getCurrentLocation();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error predicting login"),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (errorMsg) {
      return null;
    }
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
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0D47A1), Color(0xff1976D2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(
                  "Unlock Your Secure Vault",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
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
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: emailController,
                            validator: (value) =>
                                value == "" ? "Please enter email" : null,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator: (value) =>
                                value == "" ? "Please enter password" : null,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        loginUserNow();
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
                        "Login",
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
                      Get.to(const SignUpScreen());
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: primary1Color,
                        fontWeight: FontWeight.w600,
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
