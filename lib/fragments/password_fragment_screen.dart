// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';

import 'package:http/http.dart' as http;
import 'package:password_manager/user_preferences/userPreferences.dart';

class PasswordFragmentScreen extends StatefulWidget {
  const PasswordFragmentScreen({super.key});

  @override
  State<PasswordFragmentScreen> createState() => _PasswordFragmentScreenState();
}

class _PasswordFragmentScreenState extends State<PasswordFragmentScreen> {
  var formKey = GlobalKey<FormState>();
  var formKey1 = GlobalKey<FormState>();
  TextEditingController lengthController = TextEditingController();
  TextEditingController linkController = TextEditingController();

  String? generatedPassword;

  bool useUppercase = false;
  bool useNumbers = false;
  bool useSpecialChars = false;

  Future<String?> generatePassword(int length, bool use_uppercase,
      bool use_numbers, bool use_special_chars, BuildContext context) async {
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error sharing password")),
        );
        return null;
      }
    } catch (errorMsg) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
    return null;
  }

  predictPhishing(String link, BuildContext context) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(Uri.parse(API.predictPhishingIntelliVault),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "link": link,
          }));

      if (res.statusCode == 200) {
        var responseBodyOfPredictLogin = jsonDecode(res.body);
        String prediction = responseBodyOfPredictLogin["prediction"];
        if (prediction == "valid") {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Link Valid"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Phishing Detected"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error predicting phishing")),
        );
        return null;
      }
    } catch (errorMsg) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Miscellaneous"),
        backgroundColor: primary1Color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generate Password Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Generate Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary1Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (generatedPassword != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                generatedPassword!,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.black),
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: generatedPassword!));
                                Fluttertoast.showToast(
                                    msg: "Copied to clipboard");
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: lengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Length",
                              prefixIcon: const Icon(Icons.numbers),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter length";
                              }
                              final length = int.tryParse(value);
                              if (length == null || length <= 0) {
                                return "Enter positive number";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text(
                                    "Uppercase Letters",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: useUppercase,
                                  onChanged: (value) {
                                    setState(() {
                                      useUppercase = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text("Numbers"),
                                  value: useNumbers,
                                  onChanged: (value) {
                                    setState(() {
                                      useNumbers = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          CheckboxListTile(
                            title: const Text("Special Characters"),
                            value: useSpecialChars,
                            onChanged: (value) {
                              setState(() {
                                useSpecialChars = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.lock_open),
                            label: const Text("Generate Password"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                String? result = await generatePassword(
                                    int.parse(lengthController.text.trim()),
                                    useUppercase,
                                    useNumbers,
                                    useSpecialChars,
                                    context);
                                setState(() {
                                  generatedPassword = result;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Phishing Detection Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phishing Detection",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary1Color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: formKey1,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: linkController,
                            decoration: InputDecoration(
                              labelText: "URL Link",
                              prefixIcon: const Icon(Icons.link),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter URL Link";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.shield),
                            label: const Text("Detect Phishing"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () async {
                              if (formKey1.currentState!.validate()) {
                                await predictPhishing(
                                    linkController.text.trim(), context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
