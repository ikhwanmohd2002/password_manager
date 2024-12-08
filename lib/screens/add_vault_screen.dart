import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
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

class AddVaultScreen extends StatefulWidget {
  const AddVaultScreen({super.key});

  @override
  State<AddVaultScreen> createState() => _AddVaultScreenState();
}

class _AddVaultScreenState extends State<AddVaultScreen> {
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
      var res = await http.post(Uri.parse(API.vaultInfoIntelliVault),
          headers: {'Authorization': 'Token $token'},
          body: vaultModel.toJson());

      if (res.statusCode == 201) {
        Fluttertoast.showToast(msg: "Added vault");
        setState(() {
          nameController.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments(), arguments: 3);
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
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
      var res = await http.put(Uri.parse("${API.vaultInfoIntelliVault}$id/"),
          headers: {'Authorization': 'Token $token'},
          body: vaultModel.toJson());

      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "Updated vault");
        setState(() {
          nameController.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments(), arguments: 3);
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> fetchTeams() async {
    try {
      String? token = await RememberUserPrefs.readToken();

      final response = await http.get(
          Uri.parse(
            API.teamInfoIntelliVault,
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });

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
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeams();
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    teamID = hasArguments ? arguments['team'] : null;
  }

  @override
  Widget build(BuildContext context) {
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    final int? id = hasArguments ? arguments['id'] : null;
    final String? name = hasArguments ? arguments['name'] : null;
    nameController = TextEditingController(text: name ?? "");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text(hasArguments ? "Update Vault" : "Add Vault"),
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
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: primary1Color))),
                              child: TextFormField(
                                controller: nameController,
                                validator: (value) => value == ""
                                    ? "Please enter vault name"
                                    : null,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Vault Name",
                                    hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primary1Color, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primary1Color, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      hint: const Text('Select Team'),
                      value: teamID,
                      onChanged: (int? newValue) {
                        setState(() {
                          teamID = newValue;
                        });
                      },
                      items:
                          teamItems.map<DropdownMenuItem<int>>((TeamItem item) {
                        return DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(item.name),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: InkWell(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            if (hasArguments) {
                              updateVault(id!);
                            } else {
                              addVault();
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
