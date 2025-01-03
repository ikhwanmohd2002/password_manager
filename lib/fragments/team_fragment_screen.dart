import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/controllers/navigation_controller.dart';
import 'package:password_manager/screens/team_info_screen.dart';
import 'package:password_manager/model/invitation.dart';
import 'package:password_manager/model/team.dart';
import 'package:password_manager/model/team_member.dart';
import 'package:password_manager/screens/add_team_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class TeamsInfoFragmentScreen extends StatefulWidget {
  const TeamsInfoFragmentScreen({super.key});

  @override
  State<TeamsInfoFragmentScreen> createState() =>
      _TeamsInfoFragmentScreenState();
}

class _TeamsInfoFragmentScreenState extends State<TeamsInfoFragmentScreen> {
  final NavigationController navController = Get.find();
  final currentOnlineUser = Get.put(CurrentUser());
  List<Team> teams = [];
  List<int> totalTeamMembers = [];
  List<Invitation> pendingInvitations = [];
  bool isLoadingTeams = true;
  bool isLoadingInvitations = true;
  TextEditingController invitationController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchTeams();
    fetchInvitations();
  }

  Future<void> fetchTeams() async {
    try {
      List<Team> listOfTeam = [];
      List<int> listOfTotalTeamMembers = [];

      String? token = await RememberUserPrefs.readToken();
      var res = await http.get(
        Uri.parse("${API.teamInfoIntelliVault}my_teams/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (res.statusCode == 200) {
        var responseBodyOfGetTeam = jsonDecode(res.body);

        // Process each team
        for (var eachTeam in (responseBodyOfGetTeam as List)) {
          listOfTeam.add(Team.fromJson(eachTeam));

          // Fetch total team members for this team
          int totalTeamMembersForTeam =
              await fetchTotalTeamMembers(eachTeam['id']);
          listOfTotalTeamMembers.add(totalTeamMembersForTeam);
        }

        // Update state once all teams and totals are fetched
        setState(() {
          teams = listOfTeam;
          totalTeamMembers = listOfTotalTeamMembers;
          isLoadingTeams = false;
        });
      } else {
        showSnackBar("Error occurred while fetching teams.");
      }
    } catch (errorMsg) {
      showSnackBar("An error occurred while fetching teams: $errorMsg");
    }
  }

  Future<void> fetchInvitations() async {
    try {
      List<Invitation> invitations = [];

      String? token = await RememberUserPrefs.readToken();
      var res = await http.get(
        Uri.parse(API.invitationInfoIntelliVault),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (res.statusCode == 200) {
        var resBodyOfInvitation = jsonDecode(res.body);

        // Parse and add invitations
        for (var eachRecord in (resBodyOfInvitation as List)) {
          invitations.add(Invitation.fromJson(eachRecord));
        }

        // Update state once all invitations are fetched
        setState(() {
          pendingInvitations = invitations;
          isLoadingInvitations = false;
        });
      } else {
        showSnackBar("Error occurred while fetching invitations.");
      }
    } catch (errorMsg) {
      showSnackBar("An error occurred while fetching invitations: $errorMsg");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  deleteTeam(int id) async {
    try {
      var resultResponse = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
                  "Delete Team",
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
                  "Are you sure you want to delete this team? This action cannot be undone.",
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
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (resultResponse == "deleted") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http.delete(
          Uri.parse("${API.teamInfoIntelliVault}$id/"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (res.statusCode == 204) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Team deleted successfully"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            fetchTeams();
          }); // Refresh the state
        } else if (res.statusCode == 404) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Only team admins can delete team"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete the team"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  respondInvitation(int id, bool isApproved) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
        Uri.parse("${API.invitationInfoIntelliVault}$id/respond/"),
        headers: {'Authorization': 'Token $token'},
        body: {'action': isApproved ? 'accept' : 'reject'},
      );

      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved ? "Invitation Accepted" : "Invitation Rejected",
            ),
            backgroundColor: isApproved ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          fetchInvitations();
        }); // Refresh UI if needed
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to respond to the invitation."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  sendInvitation(int id) async {
    try {
      var resultResponse = await Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded edges
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                "Send Team Invitation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter the user ID of the person you want to invite.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: invitationController,
                  validator: (value) {
                    if (value == "") {
                      return "Please write user ID";
                    } else if (int.tryParse(value!) == null) {
                      return "Please write a valid user ID";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "User ID",
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
                invitationController.clear();
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.redAccent,
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
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Get.back(result: "sendRequestEmail");
                  });
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

      if (resultResponse == "sendRequestEmail") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http.post(
          Uri.parse("${API.invitationSendIntelliVault}$id/invite/"),
          headers: {'Authorization': 'Token $token'},
          body: {'recipient_id': invitationController.text.trim()},
        );

        if (res.statusCode == 201) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invitation Sent"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          invitationController.clear();
        } else if (res.statusCode == 404) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User not found"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          invitationController.clear();
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> checkIfUserAdmin(int teamId) async {
    List<TeamMember> listOfMembers = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(
        Uri.parse("${API.teamInfoIntelliVault}$teamId/members/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        },
      );
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        for (var eachMember in (responseBody as List)) {
          listOfMembers.add(TeamMember.fromJson(eachMember));
        }

        if (hasMemberWithIdAndRole(
            listOfMembers, currentOnlineUser.user.id, "admin")) {
          return true;
        }

        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  bool hasMemberWithIdAndRole(
      List<TeamMember> listOfMembers, int idToCheck, String roleToCheck) {
    return listOfMembers.any(
        (member) => member.user == idToCheck && member.role == roleToCheck);
  }

  Future<int> fetchTotalTeamMembers(int teamId) async {
    int totalTeamMembers = 0;
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
        // ignore: unused_local_variable
        for (var eachMember in (responseBody as List)) {
          totalTeamMembers += 1;
        }
        return totalTeamMembers;
      } else {
        throw Exception('Failed to load team members');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching team members: $e')),
      );
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary1Color,
        automaticallyImplyLeading: false,
        title: const Text("Teams"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Add team icon
            tooltip: "Add Team", // Tooltip for accessibility
            onPressed: () {
              // Navigate to AddTeamScreen using Get
              Get.to(() => const Add1TeamScreen());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Teams List or Empty State
          isLoadingTeams
              ? const Center(child: CircularProgressIndicator())
              : teams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.groups,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "Oh no, you're not on any team!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Make your own team and start collaborating!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Get.to(const Add1TeamScreen());
                            },
                            child: const Text("Create Team"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.group, color: Colors.white),
                              ),
                              title: Text(
                                team.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "${totalTeamMembers[index]} members",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
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
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          // View Option
                                          ListTile(
                                            leading: Icon(Icons.visibility,
                                                color: Colors.grey[700]),
                                            title: const Text("View",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              Get.to(const TeamsInfoScreen(),
                                                  arguments: {
                                                    "teamId": teams[index].id,
                                                    "teamName":
                                                        teams[index].name,
                                                    "role":
                                                        await checkIfUserAdmin(
                                                                teams[index].id)
                                                            ? "admin"
                                                            : "member"
                                                  });
                                            },
                                          ),
                                          const Divider(),
                                          // Edit Option
                                          ListTile(
                                            leading: Icon(Icons.edit,
                                                color: Colors.grey[700]),
                                            title: const Text("Edit",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Get.to(
                                                const Add1TeamScreen(),
                                                arguments: {
                                                  'id': team.id,
                                                  'name': team.name,
                                                },
                                              );
                                            },
                                          ),
                                          const Divider(),
                                          // Invite Option
                                          ListTile(
                                            leading: Icon(Icons.person_add,
                                                color: Colors.grey[700]),
                                            title: const Text("Invite",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onTap: () {
                                              Navigator.pop(context);
                                              sendInvitation(team.id);
                                            },
                                          ),
                                          const Divider(),
                                          // Delete Option
                                          ListTile(
                                            leading: Icon(Icons.delete,
                                                color: Colors.grey[700]),
                                            title: const Text("Delete",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              await deleteTeam(team.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

          // Pending Invitations
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoadingInvitations)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  if (!isLoadingInvitations && pendingInvitations.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: primary1Color, // AppBar-like background color
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons
                                .mail_outline, // Example icon for pending invitations
                            color: Colors.white, // Matches the app bar theme
                            size: 20.0,
                          ),
                          SizedBox(
                              width:
                                  8.0), // Adds some spacing between the icon and text
                          Text(
                            'Pending Invitations',
                            style: TextStyle(
                              color: Colors
                                  .white, // White text to match app bar theme
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isLoadingInvitations && pendingInvitations.isNotEmpty)
                    SizedBox(
                      height: 105, // Adjusted height to make the cards smaller
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pendingInvitations.length,
                        itemBuilder: (context, index) {
                          final invitation = pendingInvitations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            elevation:
                                1, // Reduced elevation for a subtler shadow
                            child: Container(
                              width:
                                  150, // Reduced width for a more compact look
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround, // Spaced evenly
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invitation.team.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          14, // Smaller font size for the title
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis, // Prevent overflow
                                  ),
                                  Text(
                                    "Invited by ${invitation.sender.username}",
                                    style: TextStyle(
                                      fontSize:
                                          12, // Smaller font size for subtitle
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green, size: 20),
                                        onPressed: () {
                                          respondInvitation(
                                              invitation.id, true);
                                        }, // Accept invitation
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red, size: 20),
                                        onPressed: () {
                                          respondInvitation(
                                              invitation.id, false);
                                        }, // Reject invitation
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (!isLoadingInvitations && pendingInvitations.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No Pending Invitations",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "You're all caught up!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
