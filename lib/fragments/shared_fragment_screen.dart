import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/shared_password.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SharedFragmentScreen extends StatefulWidget {
  const SharedFragmentScreen({super.key});

  @override
  State<SharedFragmentScreen> createState() => _SharedFragmentScreenState();
}

class _SharedFragmentScreenState extends State<SharedFragmentScreen> {
  final currentOnlineUser = Get.put(CurrentUser());
  List<RxBool> isObsecureV2 = [];
  final List<String> items = ['Update', 'Share', 'Delete'];
  String? selectedValue;

  final List<IconData> icons = [Icons.edit, Icons.share, Icons.delete];
  final List<Color> colors = [Colors.blue, Colors.green, Colors.red];

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  updateRequest(int shared_password_id, bool isApproved) async {
    try {
      var res = await http.post(Uri.parse(API.updateRequest), body: {
        'shared_password_id': shared_password_id.toString(),
        'status': isApproved ? 'approved' : 'rejected'
      });

      if (res.statusCode == 200) {
        var resBodyOfUpdateRequest = await jsonDecode(res.body);
        if (resBodyOfUpdateRequest['success'] == true) {
          setState(() {});
        } else {
          Fluttertoast.showToast(msg: "An error has occured, try again");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  Future<List<SharedPassword>> getPendingSharedPassword() async {
    List<SharedPassword> pendingPasswords = [];

    try {
      var res = await http.post(Uri.parse(API.getPendingSharedPassword), body: {
        'shared_user_id': currentOnlineUser.user.user_id.toString(),
        'status': "pending"
      });

      if (res.statusCode == 200) {
        var resBodyOfPending = jsonDecode(res.body);
        if (resBodyOfPending['success'] == true) {
          (resBodyOfPending['sharedPasswordItemsData'] as List)
              .forEach((eachRecord) {
            pendingPasswords.add(SharedPassword.fromJson(eachRecord));
          });
        } else {}
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: "Mak Kua");
      print(errorMsg);
    }

    return pendingPasswords;
  }

  Future<List<SharedPassword>> getSharedPassword() async {
    List<SharedPassword> sharedPasswords = [];

    try {
      var res = await http.post(Uri.parse(API.readSharedPassword), body: {
        'shared_user_id': currentOnlineUser.user.user_id.toString(),
        'status': "approved"
      });

      if (res.statusCode == 200) {
        var resBodyOfReadSharedPassword = jsonDecode(res.body);
        if (resBodyOfReadSharedPassword['success'] == true) {
          (resBodyOfReadSharedPassword['sharedPasswordItemsData'] as List)
              .forEach((eachRecord) {
            sharedPasswords.add(SharedPassword.fromJson(eachRecord));
          });
        } else {}
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: "Mak Kua");
      print(errorMsg);
    }

    return sharedPasswords;
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
              "Pending Requests",
              style: TextStyle(
                  color: primary1Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          pendingRequestPassword(context),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Shared Password",
              style: TextStyle(
                  color: primary1Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          getSharedPasswordWidget(context)
        ],
      )),
    );
  }

  Widget pendingRequestPassword(context) {
    return FutureBuilder(
        future: getPendingSharedPassword(),
        builder: (context, AsyncSnapshot<List<SharedPassword>> dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dataSnapShot.data == null) {
            return const Center(
              child: Text(
                "No pending requests",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (dataSnapShot.data!.length > 0) {
            return Container(
              height: 150,
              child: ListView.builder(
                itemCount: dataSnapShot.data!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  SharedPassword eachSharedPasswordItemData =
                      dataSnapShot.data![index];
                  return GestureDetector(
                    onTap: () {
                      //Get.to(ItemDetailScreen(itemInfo: eachClothItemData));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: 150,
                      margin: EdgeInsets.fromLTRB(index == 0 ? 16 : 8, 10,
                          index == dataSnapShot.data!.length - 1 ? 16 : 8, 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                color: Colors.grey)
                          ]),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "From " +
                                            eachSharedPasswordItemData
                                                .user_name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Title : " +
                                      eachSharedPasswordItemData
                                          .password_title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.red,
                                      child: InkWell(
                                        onTap: () {
                                          updateRequest(
                                              eachSharedPasswordItemData
                                                  .shared_password_id!,
                                              false);
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(8),
                                          height: 30,
                                          child: const Text(
                                            "Reject",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.green,
                                      child: InkWell(
                                        onTap: () {
                                          updateRequest(
                                              eachSharedPasswordItemData
                                                  .shared_password_id!,
                                              true);
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(8),
                                          height: 30,
                                          child: const Text(
                                            "Approve",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                Center(
                  child: Text(
                    "No requests pending",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          }
        });
  }

  Widget getSharedPasswordWidget(context) {
    return FutureBuilder(
        future: getSharedPassword(),
        builder: (context, AsyncSnapshot<List<SharedPassword>> dataSnapShot) {
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
                SharedPassword eachSharedPassword = dataSnapShot.data![index];

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
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eachSharedPassword.password_title!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            launchUrl(Uri.parse(
                                                eachSharedPassword
                                                    .website_url!));
                                          },
                                          child: SizedBox(
                                            width: 150,
                                            child: Text(
                                              eachSharedPassword.website_url
                                                  .toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontSize: 12,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold),
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
                                          ? eachSharedPassword.password_content
                                              .toString()
                                              .replaceAll(RegExp(r"."), "•")
                                          : eachSharedPassword.password_content
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
                                    //updateLastRetrieved(
                                    //    eachPassword.password_id!);
                                    await Clipboard.setData(ClipboardData(
                                        text: eachSharedPassword
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
                                        .map((String item) => DropdownMenuItem(
                                              value: item,
                                              child: Icon(
                                                icons[items.indexOf(item)],
                                                size: 20,
                                                color:
                                                    colors[items.indexOf(item)],
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedValue,
                                    onChanged: (String? value) {
                                      if (value == "Update") {
                                        // Get.to(EditPasswordScreen(
                                        //   passwordInfo: eachPassword,
                                        // ));
                                      } else if (value == "Share") {
                                        // sendPassword(
                                        //     eachPassword.password_id ??
                                        //         0);
                                      } else {
                                        // deletePassword(
                                        //     eachPassword.password_id ??
                                        //         0);
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
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      offset: const Offset(-10, 0),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
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
        });
  }
}
