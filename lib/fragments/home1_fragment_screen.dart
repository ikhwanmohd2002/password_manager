import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/password1.dart';
import 'package:password_manager/model/shared.dart';
import 'package:password_manager/screens/add1_password_screen.dart';
import 'package:password_manager/screens/add_password1_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class Home1FragmentScreen extends StatefulWidget {
  const Home1FragmentScreen({super.key});

  @override
  State<Home1FragmentScreen> createState() => _Home1FragmentScreenState();
}

class _Home1FragmentScreenState extends State<Home1FragmentScreen> {
  var formKey = GlobalKey<FormState>();
  List<Password1> passwords = [];
  bool isLoadingPasswords = true;
  bool isLoadingSharedPasswords = true;
  TextEditingController sharedLinkController = TextEditingController();
  TextEditingController sharedAccessPasswordController =
      TextEditingController();
  TextEditingController sharingPasswordController = TextEditingController();

  List<SharedPasswordItem> rows = [];

  @override
  void initState() {
    super.initState();
    fetchPasswords();
  }

  Future<void> sharePassword(int id) async {
    String? sharedLink;
    try {
      await Get.dialog(StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Share Password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: sharingPasswordController,
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? "Please write access password" : null,
                    decoration: InputDecoration(
                      hintText: "Access Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[400]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  if (sharedLink != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Access Code",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SelectableText(
                            sharedLink!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  sharingPasswordController.clear();
                  setState(() {
                    sharedLink = null;
                  });
                  Get.back();
                },
                child: const Text("Cancel"),
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
                    await Future.delayed(const Duration(milliseconds: 500),
                        () async {
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

                      sharingPasswordController.clear();
                    });
                  }
                },
                child: const Text("Share"),
              ),
            ],
          );
        },
      ));
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(Get.context!).showSnackBar(
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
      print(errorMsg);

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

  void _addRow(String login_username, String login_password) {
    setState(() {
      SharedPasswordItem model = SharedPasswordItem(
          login_username: login_username, login_password: login_password);
      rows.add(model);
    });
  }

  Future<void> getSharedPassword(String link, String accessPassword) async {
    SharedModel sharedModel;
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
        Uri.parse("${API.sharedPasswordIntelliVault}$link/"),
        headers: {'Authorization': 'Token $token'},
        body: {"password": accessPassword},
      );

      if (res.statusCode == 200) {
        var responseBodyOfGetSharedPassword = jsonDecode(res.body);

        sharedModel = SharedModel.fromJson(responseBodyOfGetSharedPassword);
        _addRow(
          sharedModel.item.login_username,
          sharedModel.item.login_password,
        );

        // Show success snackbar
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: const Text("Shared password accessed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: const Text("Error accessing shared password."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (errorMsg) {
      print(errorMsg);

      // Show error snackbar
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("Error: $errorMsg"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> accessSharedPassword() async {
    try {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Access Shared Password",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: sharedLinkController,
                  validator: (value) =>
                      value!.isEmpty ? "Please write shared code" : null,
                  decoration: InputDecoration(
                    hintText: "Shared Code",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sharedAccessPasswordController,
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? "Please write access password" : null,
                  decoration: InputDecoration(
                    hintText: "Access Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                sharedAccessPasswordController.clear();
                sharedLinkController.clear();
                Get.back();
              },
              child: const Text("Cancel"),
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
                  await Future.delayed(const Duration(milliseconds: 500), () {
                    getSharedPassword(
                      sharedLinkController.text.trim(),
                      sharedAccessPasswordController.text.trim(),
                    );
                    sharedAccessPasswordController.clear();
                    sharedLinkController.clear();
                    Get.back();
                  });
                }
              },
              child: const Text("Access"),
            ),
          ],
        ),
      );
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchPasswords() async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.get(Uri.parse(API.passwordInfoIntelliVault),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });

      if (res.statusCode == 200) {
        var responseBodyOfGetPassword = jsonDecode(res.body);
        List<Password1> fetchedPasswords = [];
        for (var eachPassword in (responseBodyOfGetPassword as List)) {
          fetchedPasswords.add(Password1.fromJson(eachPassword));
        }
        setState(() {
          passwords = fetchedPasswords;
          isLoadingPasswords = false;
        });
      } else {
        setState(() {
          isLoadingPasswords = false;
        });
        showSnackbar(context, "Error occurred executing query");
      }
    } catch (errorMsg) {
      print(errorMsg);
      setState(() {
        isLoadingPasswords = false;
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
            title: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 24.0,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Delete Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Are you sure you want to delete this password?\nThis action cannot be undone.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "No",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop("deleted");
                },
                child: const Text(
                  "Yes",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

        if (res.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Password deleted successfully"),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            fetchPasswords();
            // Trigger a UI update after deletion
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Failed to delete the password"),
              duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Passwords"),
        backgroundColor: primary1Color,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(Add1PasswordScreen());
              // Add functionality for adding a new password
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Passwords Section
          Expanded(
            child: isLoadingPasswords
                ? const Center(child: CircularProgressIndicator())
                : passwords.isEmpty
                    ? const Center(
                        child: Text(
                          "No passwords available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: passwords.length,
                        itemBuilder: (context, index) {
                          // Boolean to track visibility state
                          bool isPasswordVisible = false;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 2,
                                  color: Colors.grey[100],
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    title: Text(
                                      passwords[index].login_username!,
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      isPasswordVisible
                                          ? passwords[index].decrypted_password!
                                          : '••••••••',
                                      style: const TextStyle(
                                          fontSize: 12.0, color: Colors.grey),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            // Toggle password visibility
                                            setState(() {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.more_vert,
                                              color: Colors.grey),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(
                                                      20), // Add curved edges
                                                ),
                                              ),
                                              builder: (context) => Container(
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(
                                                        20), // Curved edges match the shape
                                                  ),
                                                  color: Colors
                                                      .white, // Background color
                                                ),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Add a handle to indicate draggable bottom sheet
                                                      Container(
                                                        width: 50,
                                                        height: 5,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 16),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),

                                                      // Copy Username Option
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.copy,
                                                            color: Colors
                                                                .grey[700]),
                                                        title: Text(
                                                          "Copy Username",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onTap: () async {
                                                          await Clipboard
                                                              .setData(
                                                            ClipboardData(
                                                                text: passwords[
                                                                        index]
                                                                    .login_username
                                                                    .toString()),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: const Text(
                                                                  "Username copied to clipboard"),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      Divider(
                                                          color: Colors.grey),

                                                      // Copy Password Option
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.copy,
                                                            color: Colors
                                                                .grey[700]),
                                                        title: Text(
                                                          "Copy Password",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onTap: () async {
                                                          await Clipboard
                                                              .setData(
                                                            ClipboardData(
                                                                text: passwords[
                                                                        index]
                                                                    .decrypted_password
                                                                    .toString()),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: const Text(
                                                                  "Password copied to clipboard"),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      Divider(
                                                          color: Colors.grey),

                                                      // Edit Option
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.edit,
                                                            color: Colors
                                                                .grey[700]),
                                                        title: Text(
                                                          "Edit",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          Get.to(
                                                              const Add1PasswordScreen(),
                                                              arguments: {
                                                                'id': passwords[
                                                                        index]
                                                                    .id,
                                                                'vault':
                                                                    passwords[
                                                                            index]
                                                                        .vault,
                                                                'username': passwords[
                                                                        index]
                                                                    .login_username,
                                                                'password': passwords[
                                                                        index]
                                                                    .decrypted_password
                                                              });
                                                        },
                                                      ),
                                                      Divider(
                                                          color: Colors.grey),

                                                      // Share Option
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.share,
                                                            color: Colors
                                                                .grey[700]),
                                                        title: Text(
                                                          "Share",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          sharePassword(
                                                              passwords[index]
                                                                  .id!);
                                                        },
                                                      ),
                                                      Divider(
                                                          color: Colors.grey),

                                                      // Delete Option
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons.delete,
                                                            color: Colors
                                                                .grey[700]),
                                                        title: Text(
                                                          "Delete",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context);
                                                          deletePassword(
                                                              passwords[index]
                                                                  .id!);
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
                        },
                      ),
          ),
          // Shared Passwords Section
          Container(
            decoration: BoxDecoration(
              color: primary1Color, // AppBar-like background color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.share,
                      color: Colors.white, // White icon to match app bar theme
                      size: 22.0,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Shared Passwords',
                      style: const TextStyle(
                        color:
                            Colors.white, // White text to match app bar theme
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add, // Add icon
                    color: Colors.white, // White icon to match app bar theme
                  ),
                  onPressed: () {
                    accessSharedPassword();
                  },
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (!isLoadingSharedPasswords)
                  const Center(child: CircularProgressIndicator())
                else if (rows.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 50.0,
                          color: primary1Color.withOpacity(0.6),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'No shared passwords yet',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton.icon(
                          onPressed: () {
                            accessSharedPassword();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Shared Password'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary1Color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 135.0, // Fixed height for scrollable section
                    child: ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        bool isVisible =
                            false; // Track visibility for each password

                        return StatefulBuilder(
                          builder: (context, setState) => ListTile(
                            leading:
                                const Icon(Icons.share, color: Colors.grey),
                            title: Text(rows[index].login_username),
                            subtitle: Text(
                              isVisible
                                  ? rows[index].login_password // Show password
                                  : "••••••••", // Masked password
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isVisible =
                                          !isVisible; // Toggle visibility
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              20), // Add curved edges
                                        ),
                                      ),
                                      builder: (context) => Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                20), // Curved edges match the shape
                                          ),
                                          color:
                                              Colors.white, // Background color
                                        ),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Add a handle to indicate draggable bottom sheet
                                              Container(
                                                width: 50,
                                                height: 5,
                                                margin: const EdgeInsets.only(
                                                    bottom: 16),
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
                                                title: Text(
                                                  "Copy Username",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onTap: () async {
                                                  await Clipboard.setData(
                                                    ClipboardData(
                                                        text: rows[index]
                                                            .login_username
                                                            .toString()),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                          "Username copied to clipboard"),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              Divider(color: Colors.grey),

                                              // Copy Password Option
                                              ListTile(
                                                leading: Icon(Icons.copy,
                                                    color: Colors.grey[700]),
                                                title: Text(
                                                  "Copy Password",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onTap: () async {
                                                  await Clipboard.setData(
                                                    ClipboardData(
                                                        text: rows[index]
                                                            .login_password
                                                            .toString()),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                          "Password copied to clipboard"),
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
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
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
