import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/model/password1.dart';
import 'package:password_manager/model/vault.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:http/http.dart' as http;

class VaultItem {
  final int id;
  final String name;

  VaultItem({required this.id, required this.name});

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AddPassword1Screen extends StatefulWidget {
  const AddPassword1Screen({super.key});

  @override
  State<AddPassword1Screen> createState() => _AddPassword1ScreenState();
}

class _AddPassword1ScreenState extends State<AddPassword1Screen> {
  List<VaultItem> vaultItems = [];
  int? vaultID;
  CurrentUser currentUser = Get.put(CurrentUser());

  var formKey = GlobalKey<FormState>();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs;
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  addPassword() async {
    Password1 passwordModel = Password1(
      id: 1,
      vault: vaultID,
      login_username: usernameController.text.trim(),
      login_password: passwordController.text.trim(),
    );

    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(Uri.parse(API.passwordInfoIntelliVault),
          headers: {'Authorization': 'Token $token'},
          body: passwordModel.toJson());

      if (res.statusCode == 201) {
        Fluttertoast.showToast(msg: "Added password");
        setState(() {
          usernameController.clear();
          passwordController.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments());
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  updatePassword(int id1) async {
    Password1 passwordModel = Password1(
      id: id1,
      vault: vaultID,
      login_username: usernameController.text.trim(),
      login_password: passwordController.text.trim(),
    );

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.put(
          Uri.parse("${API.passwordInfoIntelliVault}$id1/"),
          headers: {'Authorization': 'Token $token'},
          body: passwordModel.toJson());

      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "Updated password");
        setState(() {
          usernameController.clear();
          passwordController.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments(), arguments: 0);
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> fetchVaults() async {
    try {
      String? token = await RememberUserPrefs.readToken();

      final response = await http.get(
          Uri.parse(
            API.vaultInfoIntelliVault,
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          vaultItems =
              data.map<VaultItem>((item) => VaultItem.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVaults();
  }

  @override
  Widget build(BuildContext context) {
    // final hasArguments = Get.arguments != null;
    // final arguments = hasArguments ? Get.arguments : {};
    // //final int? id = hasArguments ? arguments['id'] : null;
    // final int? vault = hasArguments ? arguments['vault'] : null;
    // final String? username = hasArguments ? arguments['username'] : null;
    // final String? password = hasArguments ? arguments['password'] : null;

    // usernameController = TextEditingController(text: username ?? "");
    // passwordController = TextEditingController(text: password ?? "");

    // vaultID = vault;

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
                                controller: usernameController,
                                validator: (value) => value == ""
                                    ? "Please enter username"
                                    : null,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Username",
                                    hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: primary1Color))),
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
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: primary1Color, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: primary1Color, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              hint: const Text('Select Vault'),
                              value: vaultID,
                              onChanged: (int? newValue) {
                                setState(() {
                                  vaultID = newValue;
                                });
                              },
                              items: vaultItems
                                  .map<DropdownMenuItem<int>>((VaultItem item) {
                                return DropdownMenuItem<int>(
                                  value: item.id,
                                  child: Text(item.name),
                                );
                              }).toList(),
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
