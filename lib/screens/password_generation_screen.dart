// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';

import 'package:http/http.dart' as http;
import 'package:password_manager/user_preferences/userPreferences.dart';

class PasswordGenerationScreen extends StatefulWidget {
  const PasswordGenerationScreen({super.key});

  @override
  State<PasswordGenerationScreen> createState() =>
      _PasswordGenerationScreenState();
}

class _PasswordGenerationScreenState extends State<PasswordGenerationScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController lengthController = TextEditingController();
  int passwordLength = 4;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Password Generation"),
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
                              child: buildGeneratedPassword(generatedPassword!),
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
                    if (generatedPassword != null) const SizedBox(height: 16),
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Length Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Length: ",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "$passwordLength",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: passwordLength.toDouble(),
                            min: 4,
                            max: 40,
                            divisions: 36,
                            label: passwordLength.toString(),
                            onChanged: (value) {
                              setState(() {
                                passwordLength = value.toInt();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Options Section
                          const Text(
                            "Options",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SwitchListTile(
                            title: const Text("Digits (e.g. 345)"),
                            value: useNumbers,
                            onChanged: (value) {
                              setState(() {
                                useNumbers = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text("Uppercase (e.g. AA)"),
                            value: useUppercase,
                            onChanged: (value) {
                              setState(() {
                                useUppercase = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text("Symbols (e.g. @#)"),
                            value: useSpecialChars,
                            onChanged: (value) {
                              setState(() {
                                useSpecialChars = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
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
                                    passwordLength,
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
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGeneratedPassword(String generatedPassword) {
    return Text.rich(
      TextSpan(
        children: generatedPassword.characters.map((char) {
          if (RegExp(r'[0-9]').hasMatch(char)) {
            // Numbers: Blue
            return TextSpan(
              text: char,
              style: const TextStyle(color: Colors.blue, fontSize: 18),
            );
          } else if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:\,<>\./?\\|]')
              .hasMatch(char)) {
            // Symbols: Red
            return TextSpan(
              text: char,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            );
          } else {
            // Default style for other characters
            return TextSpan(
              text: char,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            );
          }
        }).toList(),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
