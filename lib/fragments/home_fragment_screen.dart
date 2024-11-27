// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/password1.dart';
import 'package:password_manager/model/shared.dart';
import 'package:password_manager/screens/add_password1_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/user_preferences/userPreferences.dart';

class HomeFragmentScreen extends StatefulWidget {
  const HomeFragmentScreen({super.key});

  @override
  State<HomeFragmentScreen> createState() => _HomeFragmentScreenState();
}

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  TextEditingController searchController = TextEditingController();
  final currentOnlineUser = Get.put(CurrentUser());
  List<RxBool> isObsecureV2 = [];
  List<RxBool> isObsecureV4 = [];
  final List<String> items = ['Update', 'Share', 'Delete'];
  String? selectedValue;
  var formKey = GlobalKey<FormState>();
  TextEditingController sharingPasswordController = TextEditingController();
  TextEditingController sharedEmailController = TextEditingController();
  TextEditingController sharedLinkController = TextEditingController();
  TextEditingController sharedAccessPasswordController =
      TextEditingController();

  final List<IconData> icons = [Icons.edit, Icons.share, Icons.delete];
  final List<Color> colors = [Colors.blue, Colors.green, Colors.red];

  List<SharedPasswordItem> rows = [];

  void _addRow(String login_username, String login_password) {
    setState(() {
      SharedPasswordItem model = SharedPasswordItem(
          login_username: login_username, login_password: login_password);
      rows.add(model);
    });
  }

  updateLastRetrieved(int password_id) async {
    try {
      var res = await http.post(Uri.parse(API.updatePasswordRetrieved), body: {
        'password_id': password_id.toString(),
      });

      if (res.statusCode == 200) {
        var resBodyOfUpdateLastRetrieved = await jsonDecode(res.body);
        if (resBodyOfUpdateLastRetrieved['success'] == true) {
        } else {
          Fluttertoast.showToast(msg: "An error has occured, try again");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  deletePassword(int id) async {
    try {
      var resultResponse = await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Delete Password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure\nYou want to delete password?"),
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
            .delete(Uri.parse("${API.passwordInfoIntelliVault}$id/"), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        });

        if (res.statusCode == 204) {
          Fluttertoast.showToast(msg: "Deleted password");
          setState(() {});
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<List<Password1>> getPassword1() async {
    List<Password1> listOfPassword = [];
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(Uri.parse(API.passwordInfoIntelliVault),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });

      if (res.statusCode == 200) {
        var responseBodyOfGetPassword = jsonDecode(res.body);

        for (var eachPassword in (responseBodyOfGetPassword as List)) {
          listOfPassword.add(Password1.fromJson(eachPassword));
        }
      } else {
        Fluttertoast.showToast(msg: "Error occured executing query");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }

    return listOfPassword;
  }

  getSharedPassword(String link, String access_password) async {
    SharedModel sharedModel;
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
          Uri.parse("${API.sharedPasswordIntelliVault}$link/"),
          headers: {'Authorization': 'Token $token'},
          body: {"password": access_password});

      if (res.statusCode == 200) {
        var responseBodyOfGetSharedPassword = jsonDecode(res.body);

        sharedModel = SharedModel.fromJson(responseBodyOfGetSharedPassword);
        _addRow(
            sharedModel.item.login_username, sharedModel.item.login_password);
      } else {
        Fluttertoast.showToast(msg: "Error accesing shared password");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }
  }

  Future<String?> sharingPassword(int id, String access_password) async {
    String link;
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
          Uri.parse("${API.sharePasswordIntelliVault}$id/"),
          headers: {'Authorization': 'Token $token'},
          body: {"password": access_password});

      if (res.statusCode == 201) {
        var responseBodyOfGetSharedPassword = jsonDecode(res.body);
        link = responseBodyOfGetSharedPassword["share_link"];
        Uri uri = Uri.parse(link);
        String code =
            uri.pathSegments.where((segment) => segment.isNotEmpty).last;
        return code;
      } else {
        Fluttertoast.showToast(msg: "Error sharing password");
        return null;
      }
    } catch (errorMsg) {
      print(errorMsg);
    }
    return null;
  }

  accessSharedPassword() async {
    try {
      await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Access Shared Password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: sharedLinkController,
                validator: (value) {
                  if (value == "") {
                    return "Please write shared code";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(hintText: "Shared Code"),
              ),
              TextFormField(
                controller: sharedAccessPasswordController,
                validator: (value) {
                  if (value == "") {
                    return "Please write access password";
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(hintText: "Access Password"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                sharedAccessPasswordController.clear();
                sharedLinkController.clear();
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    getSharedPassword(
                        sharedLinkController.text.toString().trim(),
                        sharedAccessPasswordController.text.toString().trim());
                    sharedAccessPasswordController.clear();
                    sharedLinkController.clear();

                    Get.back();
                  });
                }
              },
              child: const Text(
                "Access",
                style: TextStyle(color: Colors.green),
              ))
        ],
      ));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  sharePassword(int id) async {
    String? sharedLink;
    try {
      await Get.dialog(StatefulBuilder(builder: ((context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Share Password",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: sharingPasswordController,
                  validator: (value) {
                    if (value == "") {
                      return "Please write access password";
                    } else {
                      return null;
                    }
                  },
                  decoration:
                      const InputDecoration(hintText: "Access Password"),
                ),
                if (sharedLink != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SelectableText(
                      "Access Code : $sharedLink",
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  sharedAccessPasswordController.clear();
                  sharedLinkController.clear();
                  setState(() {
                    sharedLink = null;
                  });
                  Get.back();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue),
                )),
            TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Future.delayed(const Duration(milliseconds: 1000),
                        () async {
                      String? result = await sharingPassword(
                        id,
                        sharingPasswordController.text.toString().trim(),
                      );
                      setState(() {
                        sharedLink = result;
                      });
                      sharingPasswordController.clear();
                    });
                  }
                },
                child: const Text(
                  "Share",
                  style: TextStyle(color: Colors.green),
                ))
          ],
        );
      })));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
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
                  "Passwords",
                  style: TextStyle(
                      color: primary1Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              FutureBuilder(
                  future: getPassword1(),
                  builder:
                      (context, AsyncSnapshot<List<Password1>> dataSnapShot) {
                    if (dataSnapShot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (dataSnapShot.data == null) {
                      return const Center(
                        child: Text(
                          "No password found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    if (dataSnapShot.data!.isNotEmpty) {
                      return ListView.builder(
                        itemCount: dataSnapShot.data!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          isObsecureV2.add(true.obs);
                          Password1 eachPassword = dataSnapShot.data![index];

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            margin: EdgeInsets.fromLTRB(
                                0,
                                index == 0 ? 16 : 8,
                                0,
                                index == dataSnapShot.data!.length - 1
                                    ? 16
                                    : 8),
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                  horizontal: BorderSide(color: primary1Color)),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    eachPassword
                                                        .login_username!,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                          const Spacer(),
                                          Obx(
                                            () => SizedBox(
                                              width: 80,
                                              child: Text(
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                isObsecureV2[index].value
                                                    ? eachPassword
                                                        .decrypted_password
                                                        .toString()
                                                        .replaceAll(
                                                            RegExp(r"."), "•")
                                                    : eachPassword
                                                        .decrypted_password
                                                        .toString(),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Obx(() => GestureDetector(
                                                onTap: () {
                                                  isObsecureV2[index].value =
                                                      !isObsecureV2[index]
                                                          .value;
                                                },
                                                child: Icon(
                                                  isObsecureV2[index].value
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: eachPassword
                                                          .decrypted_password
                                                          .toString()));
                                              Fluttertoast.showToast(
                                                  msg: "Copied to clipboard");
                                            },
                                            child: const Icon(
                                              Icons.copy,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              customButton: const Icon(
                                                Icons.menu,
                                                size: 20,
                                              ),
                                              items: items
                                                  .map((String item) =>
                                                      DropdownMenuItem(
                                                        value: item,
                                                        child: Icon(
                                                          icons[items
                                                              .indexOf(item)],
                                                          size: 20,
                                                          color: colors[items
                                                              .indexOf(item)],
                                                        ),
                                                      ))
                                                  .toList(),
                                              value: selectedValue,
                                              onChanged: (String? value) {
                                                if (value == "Update") {
                                                  Get.to(
                                                      const AddPassword1Screen(),
                                                      arguments: {
                                                        'id': eachPassword.id,
                                                        'vault':
                                                            eachPassword.vault,
                                                        'username': eachPassword
                                                            .login_username,
                                                        'password': eachPassword
                                                            .decrypted_password
                                                      });
                                                } else if (value == "Share") {
                                                  sharePassword(
                                                      eachPassword.id!);
                                                } else {
                                                  deletePassword(
                                                      eachPassword.id!);
                                                }
                                              },
                                              buttonStyleData:
                                                  const ButtonStyleData(
                                                height: 40,
                                                width: 45,
                                              ),
                                              dropdownStyleData:
                                                  DropdownStyleData(
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
                                          const SizedBox(
                                            width: 20,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
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
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Shared Passwords",
                  style: TextStyle(
                      color: primary1Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              sharedPasswords(context),
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
              onTap: () => Get.to(const AddPassword1Screen()),
            ),
            SpeedDialChild(
              child: Icon(
                Icons.share,
                color: primary1Color,
              ),
              onTap: () {
                accessSharedPassword();
              },
            ),
          ],
        ));
  }

  Widget sharedPasswords(context) {
    return rows.isNotEmpty
        ? ListView.builder(
            itemCount: rows.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              isObsecureV4.add(true.obs);

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.fromLTRB(0, index == 0 ? 16 : 8, 0,
                    index == rows.length - 1 ? 16 : 8),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(color: primary1Color)),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rows[index].login_username,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )),
                              const Spacer(),
                              Obx(
                                () => SizedBox(
                                  width: 80,
                                  child: Text(
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    isObsecureV4[index].value
                                        ? rows[index]
                                            .login_password
                                            .toString()
                                            .replaceAll(RegExp(r"."), "•")
                                        : rows[index].login_password.toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Obx(() => GestureDetector(
                                    onTap: () {
                                      isObsecureV4[index].value =
                                          !isObsecureV4[index].value;
                                    },
                                    child: Icon(
                                      isObsecureV4[index].value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text: rows[index]
                                          .login_password
                                          .toString()));
                                  Fluttertoast.showToast(
                                      msg: "Copied to clipboard");
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              );
            },
          )
        : Container(
            padding: const EdgeInsets.only(top: 10),
            child: const Center(
              child: Text(
                "No shared passwords",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
  }
}
