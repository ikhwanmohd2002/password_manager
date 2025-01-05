// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/file1.dart';
import 'package:password_manager/model/request.dart';
import 'package:password_manager/model/vault_items.dart';
import 'package:password_manager/screens/add_file_screen.dart';
import 'package:password_manager/screens/add_password_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class VaultInfoScreen extends StatefulWidget {
  final String vaultName;
  final int id;
  final int? teamID;

  const VaultInfoScreen({
    super.key,
    required this.vaultName,
    required this.id,
    this.teamID,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VaultInfoScreenState createState() => _VaultInfoScreenState();
}

class _VaultInfoScreenState extends State<VaultInfoScreen>
    with SingleTickerProviderStateMixin {
  var formKey = GlobalKey<FormState>();
  var formKey1 = GlobalKey<FormState>();
  TextEditingController sharingPasswordController = TextEditingController();
  late TabController _tabController;
  List<bool> _isPasswordVisible = [];
  List<LoginItem> logininfo1 = [];
  List<File1> files1 = [];
  List<Request> requests1 = [];
  List<Request> requestsFiltered = [];
  bool isLoading = false;
  bool isInTeam = false;
  String? selectedFilter = "All"; // Default filter
  List<String> filters = ["All", "Create", "Update", "Delete"];

  @override
  void initState() {
    super.initState();
    if (widget.teamID != null) {
      isInTeam = true;
      fetchRequests();
    }
    fetchItems(widget.id);
    if (isInTeam) {
      _tabController = TabController(length: 3, vsync: this);
    } else {
      _tabController = TabController(length: 2, vsync: this);
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        fetchItems(widget.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchRequests() async {
    List<Request> listOfRequest = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(
          Uri.parse(
              "${API.requestInfoIntelliVault}by-team-vault/?team_vault_id=${widget.id}"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        for (var eachRequest in (responseBody as List)) {
          listOfRequest.add(Request.fromJson(eachRequest));
        }
        setState(() {
          requests1 = listOfRequest
              .where((request) => request.status != "pending")
              .toList()
            ..sort((a, b) => DateTime.parse(b.authorized_at!).compareTo(
                DateTime.parse(a.authorized_at!))); // Sort in descending order
          requestsFiltered = requests1;

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load vault activity');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching vault activity: $e')),
      );
    }
  }

  Future<void> fetchItems(int id) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http
          .get(Uri.parse("${API.vaultItemsIntelliVault}$id/items/"), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      });

      if (res.statusCode == 200) {
        var responseBodyOfGetPassword = jsonDecode(res.body);
        VaultItems vaultItems = VaultItems.fromJson(responseBodyOfGetPassword);
        setState(() {
          logininfo1 = vaultItems.loginItems;
          files1 = vaultItems.fileItems;
          _isPasswordVisible = List<bool>.filled(logininfo1.length, false);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        //showSnackbar(context, "Error occurred executing query");
      }
    } catch (errorMsg) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, "An error occurred. Please try again.");
    }
  }

  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> sharePassword(int id) async {
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
                    Icon(Icons.lock, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Share Password",
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
                        "Enter the access password to share securely.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: sharingPasswordController,
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? "Please write access password"
                            : null,
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
                      sharingPasswordController.clear();
                      setState(() {
                        sharedLink = null;
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        String? result = await sharingPassword(
                          id,
                          sharingPasswordController.text.trim(),
                        );
                        if (result != null) {
                          setState(() {
                            sharedLink = result;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password shared successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error sharing password."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
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
        ),
      );
    }
  }

  Future<String?> sharingPassword(int id, String accessPassword) async {
    String link;
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
        Uri.parse("${API.sharePasswordIntelliVault}$id/"),
        headers: {'Authorization': 'Token $token'},
        body: {"password": accessPassword},
      );

      if (res.statusCode == 201) {
        var responseBodyOfGetSharedPassword = jsonDecode(res.body);
        link = responseBodyOfGetSharedPassword["share_link"];
        Uri uri = Uri.parse(link);
        String code =
            uri.pathSegments.where((segment) => segment.isNotEmpty).last;
        return code;
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Error sharing password."),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (errorMsg) {
      // Show error snackbar
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("Error: $errorMsg"),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  deletePassword(int id) async {
    try {
      // Show confirmation dialog
      var resultResponse = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            backgroundColor: Colors.white,
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  "Delete Password",
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
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to delete this password? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss dialog without action
                },
                child: const Text(
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
                child: const Text(
                  "Delete",
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

      // Handle deletion if confirmed
      if (resultResponse == "deleted") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http.delete(
          Uri.parse("${API.passwordInfoIntelliVault}$id/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (res.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request to delete login info successfully sent"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (res.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password successfully deleted"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          fetchItems(widget.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete the password"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
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

  deleteFile(int id) async {
    try {
      var resultResponse = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          title: const Row(
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
              const SizedBox(height: 16),
              Text(
                "Are you sure you want to delete this file? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
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
              child: const Text(
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

        if (res.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request to delete file successfully sent"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (res.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File successfully deleted"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          fetchItems(widget.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text(widget.vaultName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddOptions(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Login Info"),
            Tab(text: "Files"),
            if (isInTeam) Tab(text: "Activity"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLoginInfoTab(),
                _buildFilesTab(),
                if (isInTeam) _buildVaultActivityTab()
              ],
            ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20), // Add curved edges
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20), // Curved edges match the shape
          ),
          color: Colors.white, // Background color
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Add a handle to indicate draggable bottom sheet
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Copy Username Option
          ListTile(
            leading: Icon(Icons.add_circle, color: Colors.grey[700]),
            title: const Text(
              "Add Login Info",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Get.to(() => const Add2PasswordScreen(),
                      arguments: {'vault': widget.id, 'team': widget.teamID})
                  ?.then((result) {
                if (result == 'refresh') {
                  setState(() {
                    fetchItems(widget.id);
                  });
                }
              });
            },
          ),
          const Divider(color: Colors.grey),

          // Delete Option
          ListTile(
            leading: Icon(Icons.upload_file, color: Colors.grey[700]),
            title: const Text(
              "Add File",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Get.to(() => const Add2FileScreen(),
                      arguments: {'vault': widget.id, 'team': widget.teamID})
                  ?.then((result) {
                if (result == 'refresh') {
                  setState(() {
                    fetchItems(widget.id);
                  });
                }
              });
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildLoginInfoTab() {
    return logininfo1.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.vpn_key_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Oh no, no passwords saved!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Save your first password to get started!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Get.to(() => const Add2PasswordScreen(), arguments: {
                      'vault': widget.id,
                      'team': widget.teamID
                    })?.then((result) {
                      if (result == 'refresh') {
                        setState(() {
                          fetchItems(widget.id);
                        });
                      }
                    });
                  },
                  child: const Text("Create Password"),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: logininfo1.length,
            itemBuilder: (context, index) {
              final info = logininfo1[index];
              final bool isVisible = _isPasswordVisible[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.lock, color: Colors.white),
                    ),
                    title: Text(
                      info.loginUsername,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      isVisible ? (info.loginPassword) : "●●●●●●●●",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible[index] =
                                  !_isPasswordVisible[index];
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20), // Add curved edges
                                ),
                              ),
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        20), // Curved edges match the shape
                                  ),
                                  color: Colors.white, // Background color
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

                                      // Copy Username Option
                                      ListTile(
                                        leading: Icon(Icons.copy,
                                            color: Colors.grey[700]),
                                        title: const Text(
                                          "Copy Username",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                                text: info.loginUsername
                                                    .toString()),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Username copied to clipboard"),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const Divider(color: Colors.grey),

                                      // Copy Password Option
                                      ListTile(
                                        leading: Icon(Icons.copy,
                                            color: Colors.grey[700]),
                                        title: const Text(
                                          "Copy Password",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                                text: info.loginPassword
                                                    .toString()),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Password copied to clipboard"),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const Divider(color: Colors.grey),

                                      // Edit Option
                                      ListTile(
                                        leading: Icon(Icons.edit,
                                            color: Colors.grey[700]),
                                        title: const Text(
                                          "Edit",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await Get.to(
                                              () => const Add2PasswordScreen(),
                                              arguments: {
                                                'id': info.id,
                                                'vault': info.vault,
                                                'username': info.loginUsername,
                                                'password': info.loginPassword,
                                                'team': widget.teamID
                                              })?.then((result) {
                                            if (result == 'refresh') {
                                              setState(() {
                                                fetchItems(widget.id);
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      const Divider(color: Colors.grey),

                                      // Share Option
                                      ListTile(
                                        leading: Icon(Icons.share,
                                            color: Colors.grey[700]),
                                        title: const Text(
                                          "Share",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          sharePassword(info.id);
                                        },
                                      ),
                                      const Divider(color: Colors.grey),

                                      // Delete Option
                                      ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Colors.grey[700]),
                                        title: const Text(
                                          "Delete",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          deletePassword(info.id);
                                        },
                                      ),
                                    ]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildFilesTab() {
    return files1.isEmpty
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
                    await Get.to(() => const Add2FileScreen(), arguments: {
                      'vault': widget.id,
                      'team': widget.teamID
                    })?.then((result) {
                      if (result == 'refresh') {
                        setState(() {
                          fetchItems(widget.id);
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
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: files1.length,
            itemBuilder: (context, index) {
              final file = files1[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.description,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    file.file_name, // Replace with file['file_name']
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.grey),
                        onPressed: () {
                          downloadFile(file.id, file.file_name);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
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
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                  // Share Option
                                  ListTile(
                                    leading: Icon(Icons.share,
                                        color: Colors.grey[700]),
                                    title: const Text(
                                      "Share",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      shareFile(file.id);
                                    },
                                  ),
                                  const Divider(color: Colors.grey),

                                  // Delete Option
                                  ListTile(
                                    leading: Icon(Icons.delete,
                                        color: Colors.grey[700]),
                                    title: const Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      deleteFile(file.id);
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
          );
  }

  Widget _buildVaultActivityTab() {
    return Column(
      children: [
        _buildFilterButtons(),
        Expanded(
          child: requestsFiltered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Vault Activities Available!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "All activities are up to date.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: requestsFiltered.length,
                  itemBuilder: (context, index) {
                    final request = requestsFiltered[index];
                    String action = request.action; // Action type
                    final authorizedBy = request.authorized_by?.username ??
                        "Unknown"; // Authorized by
                    final authorizedAt =
                        request.authorized_at; // Authorized at date
                    final itemType = request.item_type == "logininfo"
                        ? "Login Info"
                        : "File";

                    // Define colors based on action type
                    Color actionColor;
                    switch (action) {
                      case "create":
                        action = "Create";
                        actionColor = Colors.green;
                        break;
                      case "update":
                        action = "Update";
                        actionColor = Colors.blue;
                        break;
                      case "delete":
                        action = "Delete";
                        actionColor = Colors.red;
                        break;
                      default:
                        actionColor = Colors.grey;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Action, Authorized At, and Status Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: actionColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "$action $itemType",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: actionColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  formatDate(authorizedAt ?? 'N/A'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Status
                            Row(
                              children: [
                                const Icon(
                                  Icons.info,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Status:",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    request.status == "approved"
                                        ? "Accepted"
                                        : request.status == "rejected"
                                            ? "Rejected"
                                            : "Pending",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: request.status == "approved"
                                          ? Colors.green
                                          : request.status == "rejected"
                                              ? Colors.red
                                              : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Requested By:",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    request.requester.username,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Authorized By
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "Authorized By:",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    authorizedBy,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Item Data Details (Collapsible)
                            ExpansionTile(
                              title: const Text(
                                "Item Details",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                if (itemType == "Login Info") ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 16, color: Colors.blue),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Username:",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          request.item_data.login_username ??
                                              'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.lock,
                                          size: 16, color: Colors.redAccent),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Password:",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          request.item_data.login_password ??
                                              'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (itemType == "File") ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.description,
                                          size: 16, color: Colors.green),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "File Name:",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          request.item_data.file_name ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.folder,
                                          size: 16, color: Colors.amber),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "File Type:",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          request.item_data.file_name != null &&
                                                  request.item_data.file_name!
                                                      .contains('.')
                                              ? request.item_data.file_name!
                                                  .split('.')
                                                  .last
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton(
            icon: Icons.add_circle_outline,
            label: "Create",
            isSelected: selectedFilter == "Create",
            onTap: () {
              setState(() {
                selectedFilter = selectedFilter == "Create"
                    ? null
                    : "Create"; // Toggle filter
                requestsFiltered = _applyFilter(selectedFilter);
              });
            },
          ),
          _buildFilterButton(
            icon: Icons.edit,
            label: "Update",
            isSelected: selectedFilter == "Update",
            onTap: () {
              setState(() {
                selectedFilter = selectedFilter == "Update"
                    ? null
                    : "Update"; // Toggle filter
                requestsFiltered = _applyFilter(selectedFilter);
              });
            },
          ),
          _buildFilterButton(
            icon: Icons.delete_outline,
            label: "Delete",
            isSelected: selectedFilter == "Delete",
            onTap: () {
              setState(() {
                selectedFilter = selectedFilter == "Delete"
                    ? null
                    : "Delete"; // Toggle filter
                requestsFiltered = _applyFilter(selectedFilter);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Request> _applyFilter(String? filter) {
    if (filter == null) {
      // No filter applied, return all requests
      return requests1;
    }
    return requests1
        .where(
            (request) => request.action.toLowerCase() == filter.toLowerCase())
        .toList();
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
