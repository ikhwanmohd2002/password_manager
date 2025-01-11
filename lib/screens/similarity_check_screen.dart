// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

class SimilarityCheckScreen extends StatefulWidget {
  const SimilarityCheckScreen({super.key});

  @override
  State<SimilarityCheckScreen> createState() => _SimilarityCheckScreenState();
}

class _SimilarityCheckScreenState extends State<SimilarityCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  double? _similarityScore;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<double> checkPasswordSimilarity(String password) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
          Uri.parse("${API.checkPasswordIntelliVault}check-similarity/"),
          headers: {
            'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "password": _passwordController.text.toString().trim(),
          }));

      if (res.statusCode == 200) {
        var responseBodyOfCheckPassword = jsonDecode(res.body);
        double similarityScore =
            responseBodyOfCheckPassword["similarity_score"];

        await Future.delayed(const Duration(seconds: 2));
        return similarityScore;
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error checking password similarity")),
        );
      }
    } catch (errorMsg) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred")),
      );
    }
    return 0.0;
  }

  void _handleCheck() async {
    if (_formKey.currentState!.validate()) {
      String password = _passwordController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Checking password similarity..."),
          duration: Duration(seconds: 2),
        ),
      );

      double similarityScore = await checkPasswordSimilarity(password);

      setState(() {
        _similarityScore = similarityScore;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Similarity Check"),
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
            if (_similarityScore != null)
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
                        _similarityScore! > 70
                            ? Icons.warning
                            : Icons.check_circle,
                        color:
                            _similarityScore! > 70 ? Colors.red : Colors.green,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      // Text section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Similarity Score: ${_similarityScore!.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 16,
                                color: _similarityScore! > 70
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _similarityScore! > 70
                                  ? "The password is highly similar to a breached password."
                                  : "The password has low similarity to breached passwords.",
                              style: const TextStyle(fontSize: 14),
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
