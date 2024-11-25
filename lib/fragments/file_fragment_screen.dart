import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/file1.dart';
import 'package:password_manager/screens/add_file_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:permission_handler/permission_handler.dart';

class FileFragmentScreen extends StatefulWidget {
  const FileFragmentScreen({super.key});

  @override
  State<FileFragmentScreen> createState() => _FileFragmentScreenState();
}

class _FileFragmentScreenState extends State<FileFragmentScreen> {
  final currentOnlineUser = Get.put(CurrentUser());
  List<RxBool> isObsecureV2 = [];
  final List<String> items = ['Update', 'Share', 'Delete'];
  String? selectedValue;
  var formKey = GlobalKey<FormState>();
  TextEditingController sharedEmailController = TextEditingController();

  final List<IconData> icons = [Icons.edit, Icons.share, Icons.delete];
  final List<Color> colors = [Colors.blue, Colors.green, Colors.red];

  deleteFile(int id) async {
    try {
      var resultResponse = await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Delete File",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure\nYou want to delete file?"),
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
            .delete(Uri.parse("${API.fileInfoIntelliVault}$id/"), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        });

        if (res.statusCode == 204) {
          Fluttertoast.showToast(msg: "Deleted file");
          setState(() {});
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<List<File1>> getFile() async {
    List<File1> listOfFile = [];
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(Uri.parse(API.fileInfoIntelliVault), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      });

      if (res.statusCode == 200) {
        var responseBodyOfGetPassword = jsonDecode(res.body);

        for (var eachFile in (responseBodyOfGetPassword as List)) {
          listOfFile.add(File1.fromJson(eachFile));
        }
      } else {
        Fluttertoast.showToast(msg: "Error occured executing query");
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: "Error occured executing query");
    }

    return listOfFile;
  }

  downloadFile(int id, String fileName) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(Uri.parse("${API.downloadFileIntelliVault}$id/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });

      if (res.statusCode == 200) {
        if (await Permission.storage.request().isGranted) {
          Directory downloadsDirectory =
              Directory('/storage/emulated/0/Download');

          if (!downloadsDirectory.existsSync()) {
            downloadsDirectory.createSync(recursive: true);
          }

          final filePath = '${downloadsDirectory.path}/$fileName';
          final file = File(filePath);

          await file.writeAsBytes(res.bodyBytes);
        } else {
          Fluttertoast.showToast(msg: "Storage permission not granted.");
        }
      } else {
        Fluttertoast.showToast(msg: "Permission not granted");
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: "Error occured executing query");
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
            FutureBuilder(
                future: getFile(),
                builder: (context, AsyncSnapshot<List<File1>> dataSnapShot) {
                  if (dataSnapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (dataSnapShot.data == null) {
                    return const Center(
                      child: Text(
                        "No file found",
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
                        File1 eachFile = dataSnapShot.data![index];

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                                                  eachFile.file_name,
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
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              downloadFile(eachFile.id,
                                                  eachFile.file_name);
                                            },
                                            icon: const Icon(Icons.download)),
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
                                                // Get.to(
                                                //     const AddPassword1Screen(),
                                                //     arguments: {
                                                //       'id': eachPassword.id,
                                                //       'vault':
                                                //           eachPassword.vault,
                                                //       'username': eachPassword
                                                //           .login_username,
                                                //       'password': eachPassword
                                                //           .decrypted_password
                                                //     });
                                              } else if (value == "Share") {
                                                // sendPassword(
                                                //     eachPassword.password_id ??
                                                //         0);
                                              } else {
                                                deleteFile(eachFile.id);
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
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddFileScreen());
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
