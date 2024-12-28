import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/invitation.dart';
import 'package:password_manager/model/team.dart';
import 'package:password_manager/screens/add1_team_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class TeamsInfoFragmentScreen extends StatefulWidget {
  @override
  _TeamsInfoFragmentScreenState createState() =>
      _TeamsInfoFragmentScreenState();
}

class _TeamsInfoFragmentScreenState extends State<TeamsInfoFragmentScreen> {
  List<Team> teams = [];
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
    setState(() {
      isLoadingTeams = true;
    });

    try {
      List<Team> fetchedTeams = await getTeams();
      setState(() {
        teams = fetchedTeams;
        isLoadingTeams = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTeams = false;
      });
      showSnackBar("Failed to fetch teams");
    }
  }

  Future<void> fetchInvitations() async {
    setState(() {
      isLoadingInvitations = true;
    });

    try {
      List<Invitation> fetchedInvitations = await getInvitations();
      setState(() {
        pendingInvitations = fetchedInvitations;
        isLoadingInvitations = false;
      });
    } catch (e) {
      setState(() {
        isLoadingInvitations = false;
      });
      showSnackBar("Failed to fetch invitations");
    }
  }

  Future<List<Team>> getTeams() async {
    List<Team> listOfTeam = [];
    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http
          .get(Uri.parse("${API.teamInfoIntelliVault}my_teams/"), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token'
      });

      if (res.statusCode == 200) {
        var responseBodyOfGetTeam = jsonDecode(res.body);
        for (var eachTeam in (responseBodyOfGetTeam as List)) {
          listOfTeam.add(Team.fromJson(eachTeam));
        }
      } else {
        showSnackBar("Error occurred executing query");
      }
    } catch (errorMsg) {
      showSnackBar("An error occurred while fetching teams");
    }

    return listOfTeam;
  }

  Future<List<Invitation>> getInvitations() async {
    List<Invitation> invitations = [];

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.get(Uri.parse(API.invitationInfoIntelliVault),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token'
          });

      if (res.statusCode == 200) {
        var resBodyOfInvitation = jsonDecode(res.body);
        for (var eachRecord in (resBodyOfInvitation as List)) {
          invitations.add(Invitation.fromJson(eachRecord));
        }
      } else {
        showSnackBar("Error occurred fetching invitations");
      }
    } catch (errorMsg) {
      showSnackBar("An error occurred while fetching invitations");
    }

    return invitations;
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
            title: Row(
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
                SizedBox(height: 16),
                Text(
                  "Are you sure you want to delete this team? This action cannot be undone.",
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
                  Navigator.pop(context); // Dismiss dialog without action
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Team deleted successfully"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          setState(() {
            fetchTeams();
          }); // Refresh the state
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete the team"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      print(e);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to respond to the invitation."),
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
      print(e);
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
          title: Row(
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
                SizedBox(height: 16),
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
                    hintText: "User ID",
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
              child: Text(
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
                  Future.delayed(Duration(milliseconds: 500), () {
                    Get.back(result: "sendRequestEmail");
                  });
                }
              },
              child: Text(
                "Send",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invitation Sent"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          invitationController.clear();
        } else if (res.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("User not found"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          invitationController.clear();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary1Color,
        automaticallyImplyLeading: false,
        title: Text("Teams"),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // Add team icon
            tooltip: "Add Team", // Tooltip for accessibility
            onPressed: () {
              // Navigate to AddTeamScreen using Get
              Get.to(() => Add1TeamScreen());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Teams List or Empty State
          isLoadingTeams
              ? Center(child: CircularProgressIndicator())
              : teams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.groups,
                              size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            "Oh no, you're not on any team!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Make your own team and start collaborating!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Add logic to create a team
                            },
                            child: Text("Create Team"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(bottom: 100),
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 120),
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.group),
                            ),
                            title: Text(team.name),
                            subtitle: Text(
                              "${teams.length} members",
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.more_vert),
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
                                      color: Colors.white, // Background color
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Add a handle to indicate draggable bottom sheet
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
                                        // View Option
                                        ListTile(
                                          leading: Icon(Icons.visibility,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "View",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // Use teamId for the View logic
                                            print(
                                                "View team with ID: ${team.id}");
                                          },
                                        ),
                                        Divider(
                                            color: Colors
                                                .grey), // Divider between options
                                        // Edit Option
                                        ListTile(
                                          leading: Icon(Icons.edit,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "Edit",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Get.to(
                                              const Add1TeamScreen(),
                                              arguments: {
                                                'id': team.id,
                                                'name': team.name,
                                              },
                                            );
                                            // Use teamId for the Edit logic
                                            print(
                                                "Edit team with ID: ${team.id}");
                                          },
                                        ),
                                        Divider(
                                            color: Colors
                                                .grey), // Divider between options
                                        // Invite Option
                                        ListTile(
                                          leading: Icon(Icons.person_add,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "Invite",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            sendInvitation(team.id);
                                            // Navigate to an invite screen or handle the invite logic
                                            print(
                                                "Invite to team with ID: ${team.id}");
                                          },
                                        ),
                                        Divider(
                                            color: Colors
                                                .grey), // Divider between options
                                        // Delete Option
                                        ListTile(
                                          leading: Icon(Icons.delete,
                                              color: Colors.grey[700]),
                                          title: Text(
                                            "Delete",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await deleteTeam(team
                                                .id); // Call deleteTeam function
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Pending Invitations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!isLoadingInvitations && pendingInvitations.isNotEmpty)
                    SizedBox(
                      height: 120, // Adjusted height to make the cards smaller
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pendingInvitations.length,
                        itemBuilder: (context, index) {
                          final invitation = pendingInvitations[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
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
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround, // Spaced evenly
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invitation.team.name,
                                    style: TextStyle(
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
                                        icon: Icon(Icons.check,
                                            color: Colors.green, size: 20),
                                        onPressed: () {
                                          respondInvitation(
                                              invitation.id, true);
                                        }, // Accept invitation
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close,
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
                      padding: EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "No Pending Invitations",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
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
