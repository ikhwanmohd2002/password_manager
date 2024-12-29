import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'dart:convert';

import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/vault.dart';
import 'package:password_manager/screens/add1_vault_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class Vault1FragmentScreen extends StatefulWidget {
  @override
  _Vault1FragmentScreenState createState() => _Vault1FragmentScreenState();
}

class _Vault1FragmentScreenState extends State<Vault1FragmentScreen> {
  List<Vault> vaults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVaults();
  }

  Future<void> fetchVaults() async {
    List<Vault> listOfVault = [];
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
          listOfVault.add(Vault.fromJson(eachVault));
        }
        setState(() {
          vaults = listOfVault;
          isLoading = false;
        });
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
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
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
              SizedBox(height: 16),
              Text(
                "Are you sure you want to delete this vault? This action cannot be undone.",
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
            fetchVaults();
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
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary1Color,
        title: Text('Vaults'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.to(Add1VaultScreen());
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : vaults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock,
                          size: 64, color: Colors.grey.shade400), // Vault icon
                      SizedBox(height: 16),
                      Text(
                        "Oh no, you don't have any vaults!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Create a vault to securely store your files and passwords!",
                        textAlign: TextAlign.center, // Center align text
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(
                              Add1VaultScreen()); // Navigate to vault creation screen
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Create Vault",
                          style: TextStyle(fontSize: 16),
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
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(
                          Icons.security, // Icon for the vault
                          color: Colors.blueAccent,
                          size: 32.0,
                        ),
                        title: Text(
                          vault.name,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Creator: ${vault.owner}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '10 items',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
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
                                        Container(
                                          width: 50,
                                          height: 5,
                                          margin: EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.visibility,
                                              color: Colors.grey[700]),
                                          title: Text("View",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Divider(color: Colors.grey),
                                        ListTile(
                                          leading: Icon(Icons.edit,
                                              color: Colors.grey[700]),
                                          title: Text("Edit",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Get.to(const Add1VaultScreen(),
                                                arguments: {
                                                  'id': vault.id,
                                                  'name': vault.name,
                                                  'team': vault.team
                                                });
                                          },
                                        ),
                                        Divider(color: Colors.grey),
                                        ListTile(
                                          leading: Icon(Icons.delete,
                                              color: Colors.grey[700]),
                                          title: Text("Delete",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                      ),
                    );
                  },
                ),
    );
  }
}
