// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/password1.dart';
import 'package:password_manager/model/shared.dart';
import 'package:password_manager/screens/add_password_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class Home1FragmentScreen extends StatefulWidget {
  const Home1FragmentScreen({super.key});

  @override
  State<Home1FragmentScreen> createState() => _Home1FragmentScreenState();
}

class _Home1FragmentScreenState extends State<Home1FragmentScreen> {
  var formKey = GlobalKey<FormState>();
  List<Password1> passwords = [];
  List<Password1> filteredPasswords = [];
  bool isLoadingPasswords = true;
  bool isLoadingSharedPasswords = true;
  TextEditingController sharedLinkController = TextEditingController();
  TextEditingController sharedAccessPasswordController =
      TextEditingController();
  TextEditingController sharingPasswordController = TextEditingController();

  List<SharedPasswordItem> rows = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPasswords();
  }

  // ignore: non_constant_identifier_names
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
          const SnackBar(
            content: Text("Shared password accessed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Error accessing shared password."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (errorMsg) {
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
      await showDialog(
        context: context,
        builder: (context) {
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
                  "Access Shared Password",
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
                  const SizedBox(height: 10),
                  Text(
                      "Enter the shared code and access password to retrieve the shared password.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sharedLinkController,
                    validator: (value) =>
                        value!.isEmpty ? "Please enter the shared code" : null,
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
                    validator: (value) => value!.isEmpty
                        ? "Please enter the access password"
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  sharedAccessPasswordController.clear();
                  sharedLinkController.clear();
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                    getSharedPassword(
                      sharedLinkController.text.trim(),
                      sharedAccessPasswordController.text.trim(),
                    );
                    sharedAccessPasswordController.clear();
                    sharedLinkController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Access",
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
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
          filteredPasswords = passwords;
          isLoadingPasswords = false;
        });
      } else {
        setState(() {
          isLoadingPasswords = false;
        });
        //showSnackbar(context, "Error occurred executing query");
      }
    } catch (errorMsg) {
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

  List<Password1> _applyFilter(String? filter) {
    if (filter == "") {
      return passwords;
    }
    return passwords
        .where((password) => password.login_username!
            .toLowerCase()
            .contains(filter!.toLowerCase()))
        .toList();
  }

  Widget searchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          filteredPasswords = _applyFilter(value);
        });
      },
      decoration: InputDecoration(
        hintText: "Search...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
      ),
    );
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
            onPressed: () async {
              await Get.to(() => const Add2PasswordScreen())?.then((result) {
                if (result == 'refresh') {
                  searchController.clear;
                  setState(() {
                    fetchPasswords();
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Passwords Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
            child: searchBar(),
          ),
          Expanded(
            child: isLoadingPasswords
                ? const Center(child: CircularProgressIndicator())
                : (filteredPasswords.isEmpty && searchController.text == "")
                    ? Center(
                        child: SingleChildScrollView(
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
                                  await Get.to(() => const Add2PasswordScreen())
                                      ?.then((result) {
                                    if (result == 'refresh') {
                                      searchController.clear;
                                      setState(() {
                                        fetchPasswords();
                                      });
                                    }
                                  });
                                },
                                child: const Text("Create Password"),
                              ),
                            ],
                          ),
                        ),
                      )
                    : (filteredPasswords.isEmpty && searchController.text != "")
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
                                  "No passwords match your search.",
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
                            itemCount: filteredPasswords.length,
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
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      elevation: 2,
                                      color: Colors.white,
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          child: Icon(Icons.lock,
                                              color: Colors.white),
                                        ),
                                        title: Text(
                                          filteredPasswords[index]
                                              .login_username!,
                                          style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: Text(
                                          isPasswordVisible
                                              ? filteredPasswords[index]
                                                  .decrypted_password!
                                              : '••••••••',
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey),
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
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          20), // Add curved edges
                                                    ),
                                                  ),
                                                  builder: (context) =>
                                                      Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration:
                                                        const BoxDecoration(
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
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[300],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),

                                                          // Copy Username Option
                                                          ListTile(
                                                            leading: Icon(
                                                                Icons.copy,
                                                                color: Colors
                                                                    .grey[700]),
                                                            title: const Text(
                                                              "Copy Username",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            onTap: () async {
                                                              await Clipboard
                                                                  .setData(
                                                                ClipboardData(
                                                                    text: filteredPasswords[
                                                                            index]
                                                                        .login_username
                                                                        .toString()),
                                                              );
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      "Username copied to clipboard"),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          const Divider(
                                                              color:
                                                                  Colors.grey),

                                                          // Copy Password Option
                                                          ListTile(
                                                            leading: Icon(
                                                                Icons.copy,
                                                                color: Colors
                                                                    .grey[700]),
                                                            title: const Text(
                                                              "Copy Password",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            onTap: () async {
                                                              await Clipboard
                                                                  .setData(
                                                                ClipboardData(
                                                                    text: filteredPasswords[
                                                                            index]
                                                                        .decrypted_password
                                                                        .toString()),
                                                              );
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      "Password copied to clipboard"),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                              Navigator.pop(
                                                                  context);
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
                const Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.white, // White icon to match app bar theme
                      size: 22.0,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Shared Passwords',
                      style: TextStyle(
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
                        ElevatedButton(
                          onPressed: () {
                            accessSharedPassword();
                          },
                          child: const Text('Add Shared Password'),
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
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              20), // Add curved edges
                                        ),
                                      ),
                                      builder: (context) => Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
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
                                                title: const Text(
                                                  "Copy Username",
                                                  style: TextStyle(
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
                                                    const SnackBar(
                                                      content: Text(
                                                          "Username copied to clipboard"),
                                                      duration:
                                                          Duration(seconds: 2),
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
                                                    const SnackBar(
                                                      content: Text(
                                                          "Password copied to clipboard"),
                                                      duration:
                                                          Duration(seconds: 2),
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
