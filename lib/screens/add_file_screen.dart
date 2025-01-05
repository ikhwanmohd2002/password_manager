// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

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

class Add2FileScreen extends StatefulWidget {
  const Add2FileScreen({super.key});

  @override
  State<Add2FileScreen> createState() => _Add2FileScreenState();
}

class _Add2FileScreenState extends State<Add2FileScreen> {
  File? selectedFile;
  List<VaultItem> vaultItems = [];
  int? vaultID;
  int? teamID;
  CurrentUser currentUser = Get.put(CurrentUser());

  var formKey = GlobalKey<FormState>();

  Future<File?> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<void> pickFile() async {
    final file = await selectFile();
    if (file != null) {
      setState(() {
        selectedFile = file;
      });
    }
  }

  addFile(File file) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var request =
          http.MultipartRequest('POST', Uri.parse(API.fileInfoIntelliVault));

      request.headers['Authorization'] = 'Token $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file_uploaded',
          file.path,
        ),
      );

      request.fields['vault'] = vaultID.toString();
      request.fields['file_name'] = "LOL";
      var res = await request.send();

      if (res.statusCode == 201) {
        if (teamID == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File Added Successfullyy"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request to add file successfully sent"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add file"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> fetchVaults(int? teamID) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      final response = await http.get(
        Uri.parse(API.vaultInfoIntelliVault),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          vaultItems = data
              .map<VaultItem>((item) => VaultItem.fromJson(item))
              .where((item) => item.team == teamID)
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load vaults"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        throw Exception('Failed to load items');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    vaultID = hasArguments ? arguments['vault'] : null;
    teamID = hasArguments ? arguments['team'] : null;

    fetchVaults(teamID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primary1Color,
        title: const Text("Add File"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //const SizedBox(height: 20),
                    if (teamID == null && vaultID == null)
                      DropdownButtonFormField<int>(
                        validator: (value) {
                          if (value == null) {
                            return "Please select a vault.";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primary1Color, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          hintText: "Select Vault",
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                selectedFile != null
                                    ? selectedFile!.path.split('/').last
                                    : 'No file selected',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: selectedFile != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          flex: 2,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: pickFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary1Color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Browse",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, // Max width for the button
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (selectedFile != null) {
                              addFile(selectedFile!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select a file."),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary1Color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
