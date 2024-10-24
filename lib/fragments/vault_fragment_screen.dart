import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:http/http.dart' as http;

class VaultFragmentScreen extends StatefulWidget {
  const VaultFragmentScreen({super.key});

  @override
  State<VaultFragmentScreen> createState() => _VaultFragmentScreenState();
}

class _VaultFragmentScreenState extends State<VaultFragmentScreen> {
  TextEditingController searchController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  var timeController = TextEditingController();
  var attemptController = TextEditingController();
  var locationController = TextEditingController();

  testAI() async {
    int time = int.parse(timeController.text.trim());
    int attempt = int.parse(attemptController.text.trim());
    int location = int.parse(locationController.text.trim());

    try {
      var body1 = {'time': time, 'attempt': attempt, 'location': location};
      var res = await http.post(Uri.parse(API.testAI), body: jsonEncode(body1));

      if (res.statusCode == 200) {
        var resBodyOfSignUp = await jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(
              msg: "Login is ${resBodyOfSignUp['prediction']}");
          setState(() {
            timeController.clear();
            attemptController.clear();
            locationController.clear();
          });
          // Future.delayed(const Duration(milliseconds: 2000), () {
          //   Get.to(DashboardOfFragments());
          // });
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16,
            ),
            showSearchBarWidget(),
            const SizedBox(
              height: 24,
            ),
            Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                  color: primary1Color,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Social Media",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Spacer(),
                      Text(
                        "Last Updated : 28/7/2024",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    "Ikhwan",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "17 Items",
                    style: TextStyle(color: Colors.white, fontSize: 21),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: primary1Color))),
                      child: TextFormField(
                        controller: timeController,
                        validator: (value) =>
                            value == "" ? "Please enter time" : null,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Time 0 - 24",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: primary1Color))),
                      child: TextFormField(
                        controller: attemptController,
                        obscureText: true,
                        validator: (value) =>
                            value == "" ? "Please enter login attempts" : null,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Login Attempts",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border:
                              Border(bottom: BorderSide(color: primary1Color))),
                      child: TextFormField(
                        controller: locationController,
                        obscureText: true,
                        validator: (value) => value == ""
                            ? "Please enter location variance"
                            : null,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Location Variance",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (formKey.currentState!.validate()) {
                  testAI();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                      "Test AI",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showSearchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: searchController,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary1Color)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary2Color)),
            border: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary2Color)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                });
              },
              icon: Icon(
                Icons.clear,
                color: primary1Color,
              ),
            ),
            hintText: "Search all vaults",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: IconButton(
              onPressed: () {
                //getPassword(searchController.text);
                setState(() {});
              },
              icon: Icon(Icons.search, color: primary1Color),
            )),
      ),
    );
  }
}
