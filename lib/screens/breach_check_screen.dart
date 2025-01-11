// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

class BreachCheckScreen extends StatefulWidget {
  const BreachCheckScreen({super.key});

  @override
  State<BreachCheckScreen> createState() => _BreachCheckScreenState();
}

class _BreachCheckScreenState extends State<BreachCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  int? _breachCount;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<int> checkPasswordBreach(String password) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
          Uri.parse("${API.checkPasswordIntelliVault}check-breach/"),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "password": _passwordController.text.toString().trim(),
          }));

      if (res.statusCode == 200) {
        var responseBodyOfCheckPassword = jsonDecode(res.body);
        int breach_count = responseBodyOfCheckPassword["breach_count"];

        await Future.delayed(const Duration(seconds: 2));
        return breach_count;
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error checking password")),
        );
      }
    } catch (errorMsg) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
    return 1;
  }

  void _handleCheck() async {
    if (_formKey.currentState!.validate()) {
      String password = _passwordController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Checking password..."),
          duration: Duration(seconds: 2),
        ),
      );

      int breachCount = await checkPasswordBreach(password);

      setState(() {
        _breachCount = breachCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Breach Check"),
        backgroundColor: primary1Color,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text("Check"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _handleCheck,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_breachCount != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Icon section
                      Icon(
                        _breachCount! > 0 ? Icons.warning : Icons.check_circle,
                        color: _breachCount! > 0 ? Colors.red : Colors.green,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      // Text section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _breachCount! > 0
                                  ? "The password has been breached $_breachCount times."
                                  : "The password has not been breached!",
                              style: TextStyle(
                                fontSize: 16,
                                color: _breachCount! > 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
