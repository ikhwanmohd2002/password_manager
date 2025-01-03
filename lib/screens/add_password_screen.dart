// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/password1.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class VaultItem {
  final int id;
  final String name;
  final int? team;

  VaultItem({required this.id, required this.name, this.team});

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'],
      name: json['name'],
      team: json['team'],
    );
  }
}

class Add2PasswordScreen extends StatefulWidget {
  const Add2PasswordScreen({super.key});

  @override
  State<Add2PasswordScreen> createState() => _Add2PasswordScreenState();
}

class _Add2PasswordScreenState extends State<Add2PasswordScreen> {
  List<VaultItem> vaultItems = [];
  int? vaultID;
  int? teamID;
  var formKey = GlobalKey<FormState>();
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  final isObscure = true.obs;
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  @override
  void initState() {
    super.initState();

    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    final String? password = hasArguments ? arguments['password'] : null;
    final String? username = hasArguments ? arguments['username'] : null;
    vaultID = hasArguments ? arguments['vault'] : null;
    teamID = hasArguments ? arguments['team'] : null;

    fetchVaults(teamID);
    if (hasArguments) {
      String lol = "";
      if (password == null) {
        passNotifier.value = PasswordStrength.calculate(text: lol);
      } else {
        passNotifier.value = PasswordStrength.calculate(text: password);
      }
    }
    passwordController = TextEditingController(text: password ?? "");
    usernameController = TextEditingController(text: username ?? "");
  }

  Future<void> fetchVaults(int? teamID) async {
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
          vaultItems = data
              .map<VaultItem>((item) => VaultItem.fromJson(item))
              .where((item) => item.team == teamID)
              .toList();
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      throw Exception('Failed to load items');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasArguments = Get.arguments != null;
    final int? id = hasArguments ? Get.arguments['id'] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text(id != null ? "Update Login Info" : "Add Login Info"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username Field
                TextFormField(
                  controller: usernameController,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter username" : null,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Enter your username",
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                Obx(
                  () => TextFormField(
                    controller: passwordController,
                    obscureText: isObscure.value,
                    onChanged: (value) {
                      passNotifier.value =
                          PasswordStrength.calculate(text: value);
                    },
                    validator: (value) =>
                        value!.isEmpty ? "Please enter password" : null,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: "Enter your password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          isObscure.value = !isObscure.value;
                        },
                        child: Icon(
                          isObscure.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Vault Dropdown Field
                if (teamID == null)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: "Choose a vault",
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    hint: const Text('Select Vault'),
                    value: vaultID,
                    onChanged: (int? newValue) {
                      setState(() {
                        vaultID = newValue;
                      });
                    },
                    items:
                        vaultItems.map<DropdownMenuItem<int>>((VaultItem item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? "Please select a vault" : null,
                  ),
                const SizedBox(height: 24),

                // Password Strength and Generate Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Password Strength Checker
                    Flexible(
                      flex: 2,
                      child: PasswordStrengthChecker(
                        strength: passNotifier,
                      ),
                    ),
                    const SizedBox(width: 5), // Reduce spacing between elements
                    // Generate Button
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          Future.delayed(const Duration(milliseconds: 1000),
                              () async {
                            String? result =
                                await generatePassword(12, true, true, true);
                            setState(() {
                              passNotifier.value =
                                  PasswordStrength.calculate(text: result!);
                              passwordController.text = result;
                            });
                          });
                        },
                        child: const Text(
                          'Generate Password',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary1Color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (id != null) {
                          updatePassword(id);
                        } else {
                          addPassword();
                        }
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<String?> generatePassword(int length, bool use_uppercase,
      bool use_numbers, bool use_special_chars) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(Uri.parse(API.generatePasswordIntelliVault),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "length": length,
            "use_uppercase": use_uppercase,
            "use_numbers": use_numbers,
            "use_special_chars": use_special_chars
          }));

      if (res.statusCode == 201) {
        var responseBodyOfGeneratePassword = jsonDecode(res.body);
        String generatedPassword = responseBodyOfGeneratePassword["password"];

        return generatedPassword;
      } else {
        Fluttertoast.showToast(msg: "Error sharing password");
        return null;
      }
    } catch (errorMsg) {
      throw Exception('Failed to load items');
    }
  }

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
        // Show success snackbar
        if (teamID == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password Added Successfullyy"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request to add password successfully sent"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        setState(() {
          usernameController.clear();
          passwordController.clear();
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back();
        });
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add password"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
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
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password updated successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          usernameController.clear();
          passwordController.clear();
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      } else if (res.statusCode == 201) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request to update password successfully sent"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          usernameController.clear();
          passwordController.clear();
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update password"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
