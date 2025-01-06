// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/file1.dart';
import 'package:password_manager/model/shared.dart';
import 'package:password_manager/screens/add_file_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class File1FragmentScreen extends StatefulWidget {
  const File1FragmentScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _File1FragmentScreenState createState() => _File1FragmentScreenState();
}

class _File1FragmentScreenState extends State<File1FragmentScreen> {
  List<File1> files = [];
  List<File1> filteredFiles = [];
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
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    RememberUserPrefs().checkTokenValidity();
    fetchFiles();
  }

  List<File1> _applyFilter(String? filter) {
    if (filter == "") {
      return files;
    }
    return files
        .where((file) =>
            file.file_name.toLowerCase().contains(filter!.toLowerCase()))
        .toList();
  }

  void fetchFiles() async {
    List<File1> fetchedFiles = [];
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(Uri.parse(API.fileInfoIntelliVault), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      });

      if (res.statusCode == 200) {
        var responseBodyOfGetPassword = jsonDecode(res.body);
        fetchedFiles = (responseBodyOfGetPassword as List)
            .map((eachFile) => File1.fromJson(eachFile))
            .toList();

        setState(() {
          files = fetchedFiles;
          filteredFiles = files;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
        const SnackBar(
          content: Text("Error occurred executing query"),
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
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Storage permission not granted."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
          duration: const Duration(seconds: 3),
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
          title: const Row(
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
              child: const Text(
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
              child: const Text("Download"),
            ),
          ],
        ),
      );
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
          const SnackBar(
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
          duration: const Duration(seconds: 3),
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
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Storage permission not granted."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
          duration: const Duration(seconds: 3),
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
                title: const Row(
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
          duration: const Duration(seconds: 3),
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
          const SnackBar(
            content: Text("File shared successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        return code;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
          duration: const Duration(seconds: 3),
        ),
      );
      return null;
    }
  }

  Widget searchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          filteredFiles = _applyFilter(value);
        });
      },
      decoration: InputDecoration(
        hintText: "Search...",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary1Color,
        title: const Text('Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share), iconSize: 19,
            onPressed: () {
              accessSharedFile();
            }, // Open shared files dialog
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Get.to(() => const Add2FileScreen())?.then((result) {
                if (result == 'refresh') {
                  searchController.clear;
                  setState(() {
                    fetchFiles();
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            child: searchBar(),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : (filteredFiles.isEmpty && searchController.text == "")
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
                              onPressed: () async {
                                await Get.to(() => const Add2FileScreen())
                                    ?.then((result) {
                                  if (result == 'refresh') {
                                    searchController.clear;
                                    setState(() {
                                      fetchFiles();
                                    });
                                  }
                                });
                              },
                              child: const Text(
                                "Upload File",
                              ),
                            ),
                          ],
                        ),
                      )
                    : (filteredFiles.isEmpty && searchController.text != "")
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No files match your search.",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Try searching with a different keyword.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredFiles.length,
                            itemBuilder: (context, index) {
                              String file = filteredFiles[index].file_name;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 3,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.description,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    file,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () {
                                          downloadFile(filteredFiles[index].id,
                                              filteredFiles[index].file_name);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.share,
                                        ),
                                        onPressed: () {
                                          shareFile(filteredFiles[index].id);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
