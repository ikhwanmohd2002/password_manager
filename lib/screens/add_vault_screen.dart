// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/vault.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

class TeamItem {
  final int id;
  final String name;

  TeamItem({required this.id, required this.name});

  factory TeamItem.fromJson(Map<String, dynamic> json) {
    return TeamItem(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Add2VaultScreen extends StatefulWidget {
  const Add2VaultScreen({super.key});

  @override
  State<Add2VaultScreen> createState() => _Add2VaultScreenState();
}

class _Add2VaultScreenState extends State<Add2VaultScreen> {
  List<TeamItem> teamItems = [];
  int? teamID;
  CurrentUser currentUser = Get.put(CurrentUser());

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();

  addVault() async {
    Vault vaultModel = Vault(
      1,
      currentUser.user.id,
      teamID,
      nameController.text.trim(),
    );

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.post(
        Uri.parse(API.vaultInfoIntelliVault),
        headers: {'Authorization': 'Token $token'},
        body: vaultModel.toJson(),
      );

      if (res.statusCode == 201) {
        // Show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vault added successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          nameController.clear();
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      }
    } catch (e) {
      // Show SnackBar for errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  updateVault(int id) async {
    Vault vaultModel = Vault(
      id,
      currentUser.user.id,
      teamID,
      nameController.text.trim(),
    );

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.put(
        Uri.parse("${API.vaultInfoIntelliVault}$id/"),
        headers: {'Authorization': 'Token $token'},
        body: vaultModel.toJson(),
      );

      if (res.statusCode == 200) {
        // Show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vault updated successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          nameController.clear();
        });

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      }
    } catch (e) {
      // Show SnackBar for errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> fetchTeams() async {
    try {
      String? token = await RememberUserPrefs.readToken();

      final response = await http.get(
        Uri.parse("${API.teamInfoIntelliVault}my_teams/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          teamItems =
              data.map<TeamItem>((item) => TeamItem.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      // Show SnackBar for errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching teams: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeams();
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    teamID = hasArguments ? arguments['team'] : null;
    final String? name = hasArguments ? arguments['name'] : null;
    nameController = TextEditingController(text: name ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    final int? id = hasArguments ? arguments['id'] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primary1Color,
        title: Text(
          id != null ? "Update Vault" : "Add Vault",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),

              // Form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Vault Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Vault Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 10.0),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter the vault name" : null,
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary1Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (id != null) {
                              updateVault(id);
                            } else {
                              addVault();
                            }
                          }
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
