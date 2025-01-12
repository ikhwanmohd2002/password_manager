// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'package:password_manager/model/request.dart';
import 'package:password_manager/model/team_member.dart';
import 'package:password_manager/model/vault_info.dart';
import 'package:password_manager/model/vault_items.dart';
import 'package:password_manager/screens/add_vault_screen.dart';
import 'package:password_manager/screens/vault_info_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:intl/intl.dart';

class TeamsInfoScreen extends StatefulWidget {
  const TeamsInfoScreen({super.key});

  @override
  State<TeamsInfoScreen> createState() => _TeamssInfoFragmentScreenState();
}

class _TeamssInfoFragmentScreenState extends State<TeamsInfoScreen>
    with SingleTickerProviderStateMixin {
  CurrentUser currentUser = Get.put(CurrentUser());
  late TabController _tabController;
  List<bool> _isExpanded = [];
  List<TeamMember> teamMembers1 = [];
  List<Request> requests1 = [];
  List<VaultInfo> vaults1 = [];
  bool isLoading = true;
  String? teamName;
  String? role;
  bool isAdmin = false;
  int? teamId;

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

  Future<void> fetchVaults() async {
    List<VaultInfo> listOfVault = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(
          Uri.parse("${API.teamInfoIntelliVault}$teamId/vaults/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });
      if (response.statusCode == 200) {
        var responseBodyOfGetVault = jsonDecode(response.body);
        for (var eachVault in (responseBodyOfGetVault as List)) {
          // Create a VaultInfo object from JSON
          var vault = VaultInfo.fromJson(eachVault);

          // Fetch total items for this vault
          int totalItems = await fetchTotalItems(eachVault['id']);

          // Append totalItems to the VaultInfo object
          vault.totalItems = totalItems;

          // Add the updated VaultInfo object to the list
          listOfVault.add(vault);
        }
        setState(() {
          vaults1 = listOfVault;
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

  Future<void> fetchRequests() async {
    List<Request> listOfRequest = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(
          Uri.parse("${API.requestInfoIntelliVault}by-team/?team_id=$teamId"),
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
              .where((request) => request.status == "pending")
              .toList()
            ..sort((a, b) => DateTime.parse(a.created_at)
                .compareTo(DateTime.parse(b.created_at)));

          _isExpanded = List<bool>.filled(listOfRequest.length, false);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching requests: $e')),
      );
    }
  }

  Future<void> fetchTeamMembers() async {
    List<TeamMember> listOfMembers = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(
          Uri.parse("${API.teamInfoIntelliVault}$teamId/members/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        for (var eachMember in (responseBody as List)) {
          listOfMembers.add(TeamMember.fromJson(eachMember));
        }
        setState(() {
          teamMembers1 = listOfMembers;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load team members');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching team members: $e')),
      );
    }
  }

  respondRequest(int id, bool isApproved) async {
    try {
      String? token = await RememberUserPrefs.readToken();
      http.Response res;

      if (isApproved) {
        res = await http.post(
          Uri.parse("${API.requestInfoIntelliVault}$id/approve/"),
          headers: {'Authorization': 'Token $token'},
        );
      } else {
        res = await http.post(
          Uri.parse("${API.requestInfoIntelliVault}$id/reject/"),
          headers: {'Authorization': 'Token $token'},
        );
      }

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved ? "Request Approved" : "Request Rejected",
            ),
            backgroundColor: isApproved ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          fetchRequests();
        }); // Refresh UI if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to respond to the request."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
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
    }
  }

  exitTeam() async {
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
                "Exit Team",
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
                "Are you sure you want to exit this team? This action cannot be undone.",
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
                Get.back(result: "leave");
              },
              child: const Text(
                "Leave Team",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (resultResponse == "leave") {
        int? membershipID = teamMembers1
            .firstWhere((member) => member.user == currentUser.user.id)
            .id;
        String? token = await RememberUserPrefs.readToken();

        var res = await http.delete(
          Uri.parse("${API.teamMembershipInfoIntelliVault}$membershipID/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (res.statusCode == 204) {
          // Show success SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Exited team successfully."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Get.back(result: 'refresh');
        } else {
          // Show error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to exit team."),
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

  removeFromTeam(int id, String name) async {
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
                "Remove From Team",
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
                "Are you sure you want to remove $name from this team? This action cannot be undone.",
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
                Get.back(result: "remove");
              },
              child: const Text(
                "Remove",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (resultResponse == "remove") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http.delete(
          Uri.parse("${API.teamMembershipInfoIntelliVault}$id/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (res.statusCode == 204) {
          // Show success SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Removed $name from team successfully."),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {
            fetchTeamMembers();
          });
        } else {
          // Show error SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to remove $name from team."),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
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

  @override
  void initState() {
    super.initState();
    // Retrieve arguments using Get.arguments
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      teamId = arguments['teamId'];
      role = arguments['role'];
      teamName = arguments['teamName'];
      if (role == "member") {
        isAdmin = false;
        _tabController = TabController(length: 2, vsync: this);
      } else {
        _tabController = TabController(length: 3, vsync: this);
        isAdmin = true;
        fetchRequests();
      }
    }

    fetchTeamMembers(); // Fetch data when the screen initializes
    fetchVaults();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              fetchTeamMembers();
              break;
            case 1:
              fetchVaults();
              break;
            case 2:
              fetchRequests();
              break;
            default:
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Get.to(() => const Add2VaultScreen(),
                    arguments: {'team': teamId})?.then((result) {
                  if (result == 'refresh') {
                    setState(() {
                      fetchVaults();
                    });
                  }
                });
              },
            ),
          if (!isAdmin)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                exitTeam();
              },
            ),
        ],
        backgroundColor: primary1Color,
        title: Text(teamName ?? "Team Information"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: "Members"),
            const Tab(text: "Vaults"),
            if (isAdmin) const Tab(text: "Requests"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(),
                _buildVaultsTab(),
                if (isAdmin) _buildRequestsTab(),
              ],
            ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teamMembers1.length,
      itemBuilder: (context, index) {
        final isAdmin = teamMembers1[index].role == 'admin';
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              child:
                  Text(teamMembers1[index].username[0]), // First letter of name
            ),
            title: Text(
              teamMembers1[index].username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ), // Name of the member
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // Ensure the row fits its content
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.green[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAdmin ? 'Admin' : 'Member',
                    style: TextStyle(
                      color: isAdmin ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Add spacing between role and icon
                if (!isAdmin && teamMembers1[index].user != currentUser.user.id)
                  IconButton(
                    icon: const Icon(Icons.person_remove),
                    onPressed: () {
                      removeFromTeam(
                          teamMembers1[index].id, teamMembers1[index].username);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaultsTab() {
    return vaults1.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock,
                    size: 64, color: Colors.grey.shade400), // Vault icon
                const SizedBox(height: 16),
                Text(
                  "Oh no, this team doesnt have any vaults!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create a vault to securely store your files and passwords for team!",
                  textAlign: TextAlign.center, // Center align text
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                if (isAdmin)
                  ElevatedButton(
                    onPressed: () async {
                      await Get.to(() => const Add2VaultScreen(),
                          arguments: {'team': teamId})?.then((result) {
                        if (result == 'refresh') {
                          setState(() {
                            fetchVaults();
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
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vaults1.length,
            itemBuilder: (context, index) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                    vaults1[index].name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Creator: ${vaults1[index].owner.username}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${vaults1[index].totalItems} items',
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
                                  Container(
                                    width: 50,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.visibility,
                                        color: Colors.grey[700]),
                                    title: const Text("View",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.to(VaultInfoScreen(
                                        vaultName: vaults1[index].name,
                                        id: vaults1[index].id,
                                        teamID: vaults1[index].team,
                                      ));
                                    },
                                  ),
                                  const Divider(color: Colors.grey),
                                  if (isAdmin)
                                    ListTile(
                                      leading: Icon(Icons.edit,
                                          color: Colors.grey[700]),
                                      title: const Text("Edit",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        await Get.to(
                                            () => const Add2VaultScreen(),
                                            arguments: {
                                              'id': vaults1[index].id,
                                              'name': vaults1[index].name,
                                              'team': vaults1[index].team
                                            })?.then((result) {
                                          if (result == 'refresh') {
                                            setState(() {
                                              fetchVaults();
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  if (isAdmin)
                                    const Divider(color: Colors.grey),
                                  if (isAdmin)
                                    ListTile(
                                      leading: Icon(Icons.delete,
                                          color: Colors.grey[700]),
                                      title: const Text("Delete",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        deleteVault(vaults1[index].id);
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
          );
  }

  Widget _buildRequestsTab() {
    return requests1.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications,
                    size: 64,
                    color: Colors.grey.shade400), // Pending requests icon
                const SizedBox(height: 16),
                Text(
                  "No Pending Team Action Requests!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "All team actions are up to date.",
                  textAlign: TextAlign.center, // Center align text
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: requests1.length,
            itemBuilder: (context, index) {
              final request = requests1[index];
              String action = request.action; // update, create, delete
              final requesterUsername =
                  request.requester.username; // Requester username
              final itemType =
                  request.item_type == "logininfo" ? "Login Info" : "File";
              final requestDate = request.created_at; // Request date
              final vaultName = request.team_vault.name; // Vault name

              // Define colors based on action
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
                    borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action and Request Date Row
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
                            formatDate(requestDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Vault Name and Requester Username
                      Text(
                        "Vault: $vaultName",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Requester: $requesterUsername",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Expandable Details Section
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 12),
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
                                      request.item_data.login_username ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87),
                                      overflow: TextOverflow
                                          .ellipsis, // Ensures long text doesn't break layout
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
                                      request.item_data.login_password ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87),
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
                                          fontSize: 13, color: Colors.black87),
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
                                            .last // Extract file type
                                        : 'N/A', // Default value if no extension is found
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                        crossFadeState: _isExpanded[index]
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      const Divider(height: 16),
                      // Approve/Reject Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isExpanded[index] = !_isExpanded[index];
                              });
                            },
                            child: Text(
                              _isExpanded[index]
                                  ? "Hide Details"
                                  : "View Details",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  respondRequest(request.id, true);
                                },
                                child: const Text(
                                  "Approve",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  respondRequest(request.id, false);
                                },
                                child: const Text(
                                  "Reject",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
