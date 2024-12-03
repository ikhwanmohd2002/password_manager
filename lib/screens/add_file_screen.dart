import 'dart:convert';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:file_picker/file_picker.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
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

class AddFileScreen extends StatefulWidget {
  const AddFileScreen({super.key});

  @override
  State<AddFileScreen> createState() => _AddFileScreenState();
}

class _AddFileScreenState extends State<AddFileScreen> {
  File? selectedFile;
  List<VaultItem> vaultItems = [];
  int? vaultID;
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
        Fluttertoast.showToast(msg: "Added file");
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments());
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text("Add File"),
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
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField<int>(
                              validator: (value) {
                                if (value == null) {
                                  return "Please select vault";
                                } else {
                                  return null;
                                }
                              },
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
                    height: 10,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 3,
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 1800),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: selectedFile != null
                                  ? Text(
                                      'File: ${selectedFile!.path}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )
                                  : Text('No file selected',
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 1800),
                            child: InkWell(
                              onTap: () {
                                pickFile();
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(colors: [
                                      primary2Color,
                                      primary1Color,
                                    ])),
                                child: const Center(
                                  child: Text(
                                    "Select File",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: InkWell(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            if (selectedFile != null) {
                              addFile(selectedFile!);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please select a file");
                            }
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
