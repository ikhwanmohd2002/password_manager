// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';

import 'package:http/http.dart' as http;
import 'package:password_manager/user_preferences/userPreferences.dart';

class PhishingScreen extends StatefulWidget {
  const PhishingScreen({super.key});

  @override
  State<PhishingScreen> createState() => _PhishingScreenScreenState();
}

class _PhishingScreenScreenState extends State<PhishingScreen> {
  var formKey1 = GlobalKey<FormState>();
  TextEditingController linkController = TextEditingController();

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
        automaticallyImplyLeading: true,
        title: const Text("Phishing"),
        backgroundColor: primary1Color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    const Text(
                      "Enter Link",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
