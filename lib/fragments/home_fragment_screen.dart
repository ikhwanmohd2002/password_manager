import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/password.dart';
import 'package:password_manager/model/user.dart';
import 'package:password_manager/screens/add_password_screen.dart';
import 'package:password_manager/screens/edit_password_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomeFragmentScreen extends StatefulWidget {
  const HomeFragmentScreen({super.key});

  @override
  State<HomeFragmentScreen> createState() => _HomeFragmentScreenState();
}

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  TextEditingController searchController = TextEditingController();
  final currentOnlineUser = Get.put(CurrentUser());
  List<RxBool> isObsecureV2 = [];
  final List<String> items = ['Update', 'Share', 'Delete'];
  String? selectedValue;
  var formKey = GlobalKey<FormState>();
  TextEditingController sharedEmailController = TextEditingController();

  final List<IconData> icons = [Icons.edit, Icons.share, Icons.delete];
  final List<Color> colors = [Colors.blue, Colors.green, Colors.red];

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
      print(e);
    }
  }

  deletePassword(int password_id) async {
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
        var res = await http.post(Uri.parse(API.deletePassword), body: {
          'password_id': password_id.toString(),
        });

        if (res.statusCode == 200) {
          var resBodyOfDeletePassword = await jsonDecode(res.body);
          if (resBodyOfDeletePassword['success'] == true) {
            Fluttertoast.showToast(msg: "Deleted password");
            getPassword(searchController.text);
            setState(() {});
          } else {
            Fluttertoast.showToast(msg: "An error has occured, try again");
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  Future<List<Password>> getPassword(String? typedKeyWords) async {
    List<Password> listOfPassword = [];
    try {
      var res = await http.post(Uri.parse(API.readPassword), body: {
        "user_id": currentOnlineUser.user.user_id.toString(),
        "typedKeyWords": typedKeyWords ?? ""
      });

      if (res.statusCode == 200) {
        var responseBodyOfReadPassword = jsonDecode(res.body);
        if (responseBodyOfReadPassword['success'] == true) {
          (responseBodyOfReadPassword['passwordData'] as List)
              .forEach((eachPassword) {
            listOfPassword.add(Password.fromJson(eachPassword));
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Error occured executing query");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }

    return listOfPassword;
  }

  sendPassword(int password_id) async {
    try {
      var resultResponse = await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Share Password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: sharedEmailController,
            validator: (value) {
              if (value == "") {
                return "Please write email";
              } else if (EmailValidator.validate(value!) == false) {
                return "Please write valid email";
              } else {
                return null;
              }
            },
            decoration: InputDecoration(hintText: "name@example.com"),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                sharedEmailController.clear();
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Future.delayed(Duration(milliseconds: 1000), () {
                    Get.back(result: "sendRequestEmail");
                  });
                }
              },
              child: const Text(
                "Share",
                style: TextStyle(color: Colors.green),
              ))
        ],
      ));
      User sharedUser = User(0, "", "", "");
      if (resultResponse == "sendRequestEmail") {
        var res =
            await http.post(Uri.parse(API.validateSharedPasswordEmail), body: {
          'user_email': sharedEmailController.text.trim(),
          'own_email': currentOnlineUser.user.user_email.toString(),
        });

        if (res.statusCode == 200) {
          var resBodyOfValidateEmail = jsonDecode(res.body);
          if (resBodyOfValidateEmail['emailFound'] == true) {
            sharedUser = User.fromJson(resBodyOfValidateEmail["userData"]);
            var res1 = await http.post(Uri.parse(API.addSharedPassword), body: {
              'password_id': password_id.toString(),
              'user_id': currentOnlineUser.user.user_id.toString(),
              'shared_user_id': sharedUser.user_id.toString(),
              'status': "pending",
            });
            if (res1.statusCode == 200) {
              var resBodyOfSendPassword = await jsonDecode(res1.body);
              if (resBodyOfSendPassword['success'] == true) {
                var res2 = await http.post(Uri.parse(API.addAlert), body: {
                  'user_id': sharedUser.user_id.toString(),
                  'status': "new",
                  'type': "shared_password",
                  'description':
                      '${currentOnlineUser.user.user_email.toString()} has requested you to accept shared password'
                });
                if (res2.statusCode == 200) {
                  var resBodyOfAddAlert = await jsonDecode(res2.body);
                  if (resBodyOfAddAlert['success'] == true) {}
                }
                Fluttertoast.showToast(msg: "Request Sent");
                sharedEmailController.clear();
              } else {
                Fluttertoast.showToast(msg: "An error has occured, try again");
              }
            }
          } else {
            Fluttertoast.showToast(msg: "Email not found");
            sharedEmailController.clear();
          }
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
    getPassword("");
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
            showSearchBarWidget(),
            const SizedBox(
              height: 24,
            ),
            FutureBuilder(
                future: getPassword(searchController.text),
                builder: (context, AsyncSnapshot<List<Password>> dataSnapShot) {
                  if (dataSnapShot.connectionState == ConnectionState.waiting) {
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

                  if (dataSnapShot.data!.length > 0) {
                    return ListView.builder(
                      itemCount: dataSnapShot.data!.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        isObsecureV2.add(true.obs);
                        Password eachPassword = dataSnapShot.data![index];

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          margin: EdgeInsets.fromLTRB(0, index == 0 ? 16 : 8, 0,
                              index == dataSnapShot.data!.length - 1 ? 16 : 8),
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
                                            padding: const EdgeInsets.only(
                                                right: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  eachPassword.password_title!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    launchUrl(Uri.parse(
                                                        eachPassword
                                                            .website_url!));
                                                  },
                                                  child: SizedBox(
                                                    width: 150,
                                                    child: Text(
                                                      eachPassword.website_url
                                                          .toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontSize: 12,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          width: 24,
                                        ),
                                        Obx(
                                          () => SizedBox(
                                            width: 80,
                                            child: Text(
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              isObsecureV2[index].value
                                                  ? eachPassword
                                                      .password_content
                                                      .toString()
                                                      .replaceAll(
                                                          RegExp(r"."), "•")
                                                  : eachPassword
                                                      .password_content
                                                      .toString(),
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
                                                isObsecureV2[index].value =
                                                    !isObsecureV2[index].value;
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
                                            updateLastRetrieved(
                                                eachPassword.password_id!);
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: eachPassword
                                                        .password_content
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
                                                Get.to(EditPasswordScreen(
                                                  passwordInfo: eachPassword,
                                                ));
                                              } else if (value == "Share") {
                                                sendPassword(
                                                    eachPassword.password_id ??
                                                        0);
                                              } else {
                                                deletePassword(
                                                    eachPassword.password_id ??
                                                        0);
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
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddPasswordScreen());
        },
        backgroundColor: primary1Color,
        child: const Icon(Icons.add),
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
            hintText: "Search all items",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: IconButton(
              onPressed: () {
                getPassword(searchController.text);
                setState(() {});
              },
              icon: Icon(Icons.search, color: primary1Color),
            )),
      ),
    );
  }
}
