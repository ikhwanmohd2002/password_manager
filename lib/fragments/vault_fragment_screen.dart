import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/model/vault.dart';
import 'package:password_manager/screens/add_vault_screen.dart';
import 'package:password_manager/screens/new_home_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class VaultFragmentScreen extends StatefulWidget {
  const VaultFragmentScreen({super.key});

  @override
  State<VaultFragmentScreen> createState() => _VaultFragmentScreenState();
}

class _VaultFragmentScreenState extends State<VaultFragmentScreen> {
  TextEditingController searchController = TextEditingController();
  final List<String> items = ['Update', 'Share', 'Delete'];
  final List<IconData> icons = [Icons.edit, Icons.share, Icons.delete];
  final List<Color> colors = [Colors.blue, Colors.green, Colors.red];
  String? selectedValue;

  final currentOnlineUser = Get.put(CurrentUser());

  Future<List<Vault>> getVault() async {
    List<Vault> listOfVault = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.get(Uri.parse(API.vaultInfoIntelliVault), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      });

      if (res.statusCode == 200) {
        var responseBodyOfGetVault = jsonDecode(res.body);
        for (var eachVault in (responseBodyOfGetVault as List)) {
          listOfVault.add(Vault.fromJson(eachVault));
        }
      } else {
        Fluttertoast.showToast(msg: "Error occured executing query");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }

    return listOfVault;
  }

  deleteVault(int id) async {
    try {
      var resultResponse = await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Delete Password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure\nYou want to delete vault?"),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () {
                Get.back(result: "deleted");
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ));

      if (resultResponse == "deleted") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http
            .delete(Uri.parse("${API.vaultInfoIntelliVault}$id/"), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        });

        if (res.statusCode == 204) {
          Fluttertoast.showToast(msg: "Deleted vault");
          setState(() {});
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    RememberUserPrefs().checkTokenValidity();
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
                "Vaults",
                style: TextStyle(
                    color: primary1Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            FutureBuilder(
                future: getVault(),
                builder: (context, AsyncSnapshot<List<Vault>> dataSnapShot) {
                  if (dataSnapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (dataSnapShot.data == null) {
                    return const Center(
                      child: Text(
                        "No vault found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (dataSnapShot.data!.length > 0) {
                    return ListView.builder(
                      itemCount: dataSnapShot.data!.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        Vault eachVault = dataSnapShot.data![index];

                        return GestureDetector(
                          onTap: () {
                            Get.to(HomePage());
                            print(eachVault.id);
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 90,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 20, horizontal: 20),
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                          offset: Offset(0, 3),
                                          blurRadius: 6,
                                          color: Colors.grey)
                                    ],
                                    color: primary1Color,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eachVault.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          currentOnlineUser.user.username,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        customButton: const Icon(
                                          Icons.menu,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        items: items
                                            .map((String item) =>
                                                DropdownMenuItem(
                                                  value: item,
                                                  child: Icon(
                                                    icons[items.indexOf(item)],
                                                    size: 20,
                                                    color: colors[
                                                        items.indexOf(item)],
                                                  ),
                                                ))
                                            .toList(),
                                        value: selectedValue,
                                        onChanged: (String? value) {
                                          if (value == "Update") {
                                            print(eachVault.team);
                                            Get.to(const AddVaultScreen(),
                                                arguments: {
                                                  'id': eachVault.id,
                                                  'name': eachVault.name,
                                                  'team': eachVault.team
                                                });
                                          } else if (value == "Share") {
                                            // sendPassword(
                                            //     eachPassword.password_id ??
                                            //         0);
                                          } else {
                                            deleteVault(eachVault.id);
                                          }
                                        },
                                        buttonStyleData: const ButtonStyleData(
                                          height: 40,
                                          width: 45,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          offset: const Offset(-10, 0),
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "Empty, No Data",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        onPressed: () {
          Get.to(const AddVaultScreen());
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget showSearchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: searchController,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary1Color)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary2Color)),
            border: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary2Color)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                });
              },
              icon: Icon(
                Icons.clear,
                color: primary1Color,
              ),
            ),
            hintText: "Search all vaults",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: IconButton(
              onPressed: () {
                //getPassword(searchController.text);
                setState(() {});
              },
              icon: Icon(Icons.search, color: primary1Color),
            )),
      ),
    );
  }
}
