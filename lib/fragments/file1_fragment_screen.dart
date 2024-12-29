import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/file1.dart';
import 'package:password_manager/model/shared.dart';
import 'package:password_manager/screens/add1_file_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class File1FragmentScreen extends StatefulWidget {
  @override
  _File1FragmentScreenState createState() => _File1FragmentScreenState();
}

class _File1FragmentScreenState extends State<File1FragmentScreen> {
  List<File1> files = [];
  bool isLoading = true;
  var formKey = GlobalKey<FormState>();
  var formKey1 = GlobalKey<FormState>();
  TextEditingController sharedEmailController = TextEditingController();
  TextEditingController sharedLinkController = TextEditingController();
  TextEditingController sharedFileIDController = TextEditingController();
  TextEditingController sharedFileNameController = TextEditingController();
  TextEditingController sharingFileController = TextEditingController();
  TextEditingController sharingPasswordController = TextEditingController();
  TextEditingController sharedAccessPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    RememberUserPrefs().checkTokenValidity();
    fetchFiles();
  }

  void fetchFiles() async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(Uri.parse(API.fileInfoIntelliVault), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      });

      if (res.statusCode == 200) {
        var responseBodyOfGetPassword = jsonDecode(res.body);

        setState(() {
          files = (responseBodyOfGetPassword as List)
              .map((eachFile) => File1.fromJson(eachFile))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred executing query"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (errorMsg) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred executing query"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  deleteFile(int id) async {
    try {
      var resultResponse = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                "Delete File",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 16),
              Text(
                "Are you sure you want to delete this file? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, "deleted"); // Return result
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (resultResponse == "deleted") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http.delete(
          Uri.parse("${API.fileInfoIntelliVault}$id/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (res.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File deleted successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            files.removeWhere(
                (file) => file.id == id); // Update list after delete
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete file"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  downloadFile(int id, String fileName) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(
        Uri.parse("${API.downloadFileIntelliVault}$id/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File downloaded successfully to $filePath"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Storage permission not granted."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to download file."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (errorMsg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred: $errorMsg"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  accessSharedFile() async {
    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          title: Row(
            children: [
              Icon(Icons.file_open, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Download Shared File",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter the shared code and access password to download the file.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: sharedLinkController,
                  validator: (value) {
                    if (value == "") {
                      return "Please enter the shared code.";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Shared Code",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: sharedAccessPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == "") {
                      return "Please enter the access password.";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Access Password",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                sharedLinkController.clear();
                sharedAccessPasswordController.clear();
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await getSharedFile(
                    sharedLinkController.text.trim(),
                    sharedAccessPasswordController.text.trim(),
                  );
                  sharedLinkController.clear();
                  sharedAccessPasswordController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Download"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  getSharedFile(String link, String password) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
        Uri.parse("${API.sharedPasswordIntelliVault}$link/"),
        headers: {'Authorization': 'Token $token'},
        body: {"password": password},
      );

      if (res.statusCode == 200) {
        var responseBodyOfGetSharedFile = jsonDecode(res.body);
        SharedModelFile sharedModel =
            SharedModelFile.fromJson(responseBodyOfGetSharedFile);
        await downloadSharedFile(
          sharedModel.item.file_download_link,
          sharedModel.item.file_name,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error accessing shared file."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (errorMsg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${errorMsg.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  downloadSharedFile(String link, String fileName) async {
    String? accessCode;
    String? fileId;
    RegExp pattern = RegExp(r"/vault/file/download/(\d+)/([\w\d]+)/");
    Match? match = pattern.firstMatch(link);

    if (match != null) {
      fileId = match.group(1)!;
      accessCode = match.group(2)!;
    }

    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(
        Uri.parse("${API.downloadFileIntelliVault}$fileId/$accessCode/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("File downloaded successfully to $filePath"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Storage permission not granted."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to download the file."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (errorMsg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${errorMsg.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  shareFile(int id) async {
    String? sharedLink;
    try {
      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                title: Row(
                  children: [
                    Icon(Icons.share, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      "Share File",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Form(
                  key: formKey1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enter an access password to share securely.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: true,
                        controller: sharingPasswordController,
                        validator: (value) {
                          if (value == "") {
                            return "Please enter an access password.";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Access Password",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (sharedLink != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SelectableText(
                            "Access Code: $sharedLink",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        sharedLink = null;
                        sharingPasswordController.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: sharedLink == null
                        ? () async {
                            if (formKey1.currentState!.validate()) {
                              String? result = await sharingFile(
                                id,
                                sharingPasswordController.text
                                    .toString()
                                    .trim(),
                              );
                              setState(() {
                                sharedLink = result;
                              });
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          sharedLink == null ? Colors.green : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String?> sharingFile(int id, String password) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
        Uri.parse("${API.shareFileIntelliVault}$id/"),
        headers: {'Authorization': 'Token $token'},
        body: {"password": password},
      );

      if (res.statusCode == 201) {
        var responseBodyOfGetSharedPassword = jsonDecode(res.body);
        String link = responseBodyOfGetSharedPassword["share_link"];
        Uri uri = Uri.parse(link);
        String code =
            uri.pathSegments.where((segment) => segment.isNotEmpty).last;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File shared successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        return code;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error sharing file."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return null;
      }
    } catch (errorMsg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${errorMsg.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary1Color,
        title: Text('Files'),
        actions: [
          IconButton(
            icon: Icon(Icons.share), iconSize: 19,
            onPressed: () {
              accessSharedFile();
            }, // Open shared files dialog
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.to(Add1FileScreen());
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_open, // Represents files or a folder
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Oh no, no files found!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Upload your first file to get started!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(Add1FileScreen());
                        },
                        child: const Text(
                          "Upload File",
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    String file = files[index].file_name;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          Icons.insert_drive_file,
                          size: 32,
                        ),
                        title: Text(
                          file,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.download),
                              onPressed: () {
                                downloadFile(
                                    files[index].id, files[index].file_name);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Add a handle to indicate draggable bottom sheet
                                        Container(
                                          width: 50,
                                          height: 5,
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),

                                        // Edit Option
                                        ListTile(
                                          leading: Icon(Icons.edit,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "Edit",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Divider(color: Colors.grey),

                                        // Share Option
                                        ListTile(
                                          leading: Icon(Icons.share,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "Share",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            shareFile(files[index].id);
                                          },
                                        ),
                                        Divider(color: Colors.grey),

                                        // Delete Option
                                        ListTile(
                                          leading: Icon(Icons.delete,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "Delete",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            deleteFile(files[index].id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
