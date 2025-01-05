// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'dart:convert';

import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/vault_info.dart';
import 'package:password_manager/model/vault_items.dart';
import 'package:password_manager/screens/add_vault_screen.dart';
import 'package:password_manager/screens/vault_info_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class Vault1FragmentScreen extends StatefulWidget {
  const Vault1FragmentScreen({super.key});
  @override
  State<Vault1FragmentScreen> createState() => _Vault1FragmentScreenState();
}

class _Vault1FragmentScreenState extends State<Vault1FragmentScreen> {
  List<VaultInfo> vaults = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVaults(null);
  }

  Future<void> fetchVaults(String? search) async {
    List<VaultInfo> listOfVault = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(Uri.parse(API.vaultInfoIntelliVault),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });
      if (response.statusCode == 200) {
        var responseBodyOfGetVault = jsonDecode(response.body);
        for (var eachVault in (responseBodyOfGetVault as List)) {
          // Create a VaultInfo object from JSON
          var vault = VaultInfo.fromJson(eachVault);

          // If the vault is not part of a team, fetch and set total items
          if (vault.team == null) {
            int totalItems = await fetchTotalItems(eachVault['id']);
            vault.totalItems =
                totalItems; // Append totalItems to the VaultInfo object
          }

          // Add the updated VaultInfo object to the list
          listOfVault.add(vault);
        }

        if (search != null) {
          setState(() {
            vaults = listOfVault
                .where((vault) =>
                    vault.name.toLowerCase().contains(search.toLowerCase()) &&
                    vault.team == null)
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            vaults = listOfVault.where((vault) => vault.team == null).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load vaults');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching vaults: $e')),
      );
    }
  }

  deleteVault(int id) async {
    try {
      var resultResponse = await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
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
                "Delete Vault",
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
                "Are you sure you want to delete this vault? This action cannot be undone.",
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
                Get.back(); // Dismiss the dialog
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                Get.back(result: "deleted"); // Return "deleted" to proceed
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
        ),
      );

      if (resultResponse == "deleted") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http.delete(
          Uri.parse("${API.vaultInfoIntelliVault}$id/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (res.statusCode == 204) {
          // Show success SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vault deleted successfully."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            fetchVaults(searchController.text);
          });
        } else {
          // Show error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete vault."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<int> fetchTotalItems(int id) async {
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
        int totalItems =
            vaultItems.loginItems.length + vaultItems.fileItems.length;

        return totalItems;
      }
      return 0;
    } catch (errorMsg) {
      return 0;
    }
  }

  Widget searchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        fetchVaults(value);
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
        title: const Text('Vaults'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Get.to(() => const Add2VaultScreen())?.then((result) {
                if (result == 'refresh') {
                  setState(() {
                    fetchVaults(null);
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
                : (vaults.isEmpty && searchController.text == "")
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock,
                                size: 64,
                                color: Colors.grey.shade400), // Vault icon
                            const SizedBox(height: 16),
                            Text(
                              "Oh no, you don't have any vaults!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create a vault to securely store your files and passwords!",
                              textAlign: TextAlign.center, // Center align text
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                await Get.to(() => const Add2VaultScreen())
                                    ?.then((result) {
                                  if (result == 'refresh') {
                                    setState(() {
                                      fetchVaults(null);
                                    });
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Create Vault",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (vaults.isEmpty && searchController.text != "")
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
                                  "No vaults match your search.",
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
                            itemCount: vaults.length,
                            itemBuilder: (context, index) {
                              final vault = vaults[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 4,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.security, // Icon for the vault
                                    color: Colors.blueAccent,
                                    size: 32.0,
                                  ),
                                  title: Text(
                                    vault.name,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Creator: ${vault.owner.username}',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${vault.totalItems} items',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context) => Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: const BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 5,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                        Icons.visibility,
                                                        color:
                                                            Colors.grey[700]),
                                                    title: const Text("View",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      Get.to(VaultInfoScreen(
                                                        vaultName: vault.name,
                                                        id: vault.id,
                                                        teamID: vault.team,
                                                      ));
                                                    },
                                                  ),
                                                  const Divider(
                                                      color: Colors.grey),
                                                  ListTile(
                                                    leading: Icon(Icons.edit,
                                                        color:
                                                            Colors.grey[700]),
                                                    title: const Text("Edit",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      await Get.to(
                                                          () =>
                                                              const Add2VaultScreen(),
                                                          arguments: {
                                                            'id': vault.id,
                                                            'name': vault.name,
                                                            'team': vault.team
                                                          })?.then((result) {
                                                        if (result ==
                                                            'refresh') {
                                                          setState(() {
                                                            fetchVaults(null);
                                                          });
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  const Divider(
                                                      color: Colors.grey),
                                                  ListTile(
                                                    leading: Icon(Icons.delete,
                                                        color:
                                                            Colors.grey[700]),
                                                    title: const Text("Delete",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      deleteVault(vault.id);
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12.0),
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
