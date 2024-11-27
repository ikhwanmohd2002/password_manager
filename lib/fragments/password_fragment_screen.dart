// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  TextEditingController lengthController = TextEditingController();

  String? generatedPassword;

  bool useUppercase = false;
  bool useNumbers = false;
  bool useSpecialChars = false;

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
    } catch (errorMsg) {}
    return null;
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Generate Password",
                  style: TextStyle(
                      color: primary1Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              if (generatedPassword != null)
                const SizedBox(
                  height: 10,
                ),
              if (generatedPassword != null)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            generatedPassword!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(
                                text: generatedPassword.toString()));
                            Fluttertoast.showToast(msg: "Copied to clipboard");
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 20,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  style: const TextStyle(fontSize: 12),
                                  controller: lengthController,
                                  decoration: const InputDecoration(
                                    labelText: 'Length',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter length';
                                    }
                                    final length = int.tryParse(value);
                                    if (length == null || length <= 0) {
                                      return 'Enter postive number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: CheckboxListTile(
                                title: const Text(
                                  'Uppercase Letters',
                                  style: TextStyle(fontSize: 12),
                                ),
                                value: useUppercase,
                                onChanged: (value) {
                                  setState(() {
                                    useUppercase = value!;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: CheckboxListTile(
                                title: const Text('Numbers',
                                    style: TextStyle(fontSize: 12)),
                                value: useNumbers,
                                onChanged: (value) {
                                  setState(() {
                                    useNumbers = value!;
                                  });
                                },
                              ),
                            ),
                            Flexible(
                              child: CheckboxListTile(
                                title: const Text('Special Characters',
                                    style: TextStyle(fontSize: 12)),
                                value: useSpecialChars,
                                onChanged: (value) {
                                  setState(() {
                                    useSpecialChars = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Future.delayed(const Duration(milliseconds: 1000),
                                  () async {
                                String? result = await generatePassword(
                                    int.parse(lengthController.text
                                        .toString()
                                        .trim()),
                                    useUppercase,
                                    useNumbers,
                                    useSpecialChars);
                                setState(() {
                                  generatedPassword = result;
                                });
                              });
                            }
                          },
                          child: const Text('Generate Password'),
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: primary1Color,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          children: [
            SpeedDialChild(
              child: Icon(
                Icons.add,
                color: primary1Color,
              ),
              onTap: () {
                //Get.to(const AddPassword1Screen());
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.share,
                color: primary1Color,
              ),
              onTap: () {
                //accessSharedPassword();
              },
            ),
          ],
        ));
  }
}
