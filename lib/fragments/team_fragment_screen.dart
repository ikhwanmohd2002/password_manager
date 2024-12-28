import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/invitation.dart';
import 'package:password_manager/model/team.dart';
import 'package:password_manager/screens/add_team_screen.dart';
import 'package:password_manager/screens/team_screen.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

class TeamFragmentScreen extends StatefulWidget {
  const TeamFragmentScreen({super.key});

  @override
  State<TeamFragmentScreen> createState() => _TeamFragmentScreenState();
}

class _TeamFragmentScreenState extends State<TeamFragmentScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController invitationController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  final List<String> items = ['Update', 'Share', 'Delete'];
  final List<IconData> icons = [Icons.edit, Icons.share, Icons.delete];
  final List<Color> colors = [Colors.blue, Colors.green, Colors.red];
  String? selectedValue;

  final currentOnlineUser = Get.put(CurrentUser());

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
        Fluttertoast.showToast(msg: "Error occured executing query");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }

    return listOfTeam;
  }

  deleteTeam(int id) async {
    try {
      var resultResponse = await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Delete Team",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure\nYou want to delete team?"),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () {
                Get.back(result: "deleted");
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ));

      if (resultResponse == "deleted") {
        String? token = await RememberUserPrefs.readToken();

        var res = await http
            .delete(Uri.parse("${API.teamInfoIntelliVault}$id/"), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        });

        if (res.statusCode == 204) {
          Fluttertoast.showToast(msg: "Deleted team");
          setState(() {});
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
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
      }
    } catch (errorMsg) {
      print(errorMsg);
    }

    return invitations;
  }

  respondInvitation(int id, bool isApproved) async {
    try {
      String? token = await RememberUserPrefs.readToken();

      var res = await http.post(
          Uri.parse("${API.invitationInfoIntelliVault}$id/respond/"),
          headers: {'Authorization': 'Token $token'},
          body: {'action': isApproved ? 'accept' : 'reject'});

      if (res.statusCode == 200) {
        Fluttertoast.showToast(
            msg: isApproved ? "Invitation Accepted" : "Invitation Rejected");

        setState(() {});
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  sendInvitation(int id) async {
    try {
      var resultResponse = await Get.dialog(AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Send Team Invitation",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: invitationController,
            validator: (value) {
              if (value == "") {
                return "Please write user ID";
              } else if (int.tryParse(value!) == null) {
                return "Please write valid user ID";
              } else {
                return null;
              }
            },
            decoration: const InputDecoration(hintText: "(User ID)"),
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
                style: TextStyle(color: Colors.blue),
              )),
          TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Future.delayed(Duration(milliseconds: 1000), () {
                    Get.back(result: "sendRequestEmail");
                  });
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(color: Colors.green),
              ))
        ],
      ));
      String? token = await RememberUserPrefs.readToken();

      if (resultResponse == "sendRequestEmail") {
        var res = await http.post(
            Uri.parse("${API.invitationSendIntelliVault}$id/invite/"),
            headers: {
              'Authorization': 'Token $token'
            },
            body: {
              'recipient_id': invitationController.text.trim(),
            });

        if (res.statusCode == 201) {
          Fluttertoast.showToast(msg: "Invitation Sent");
          invitationController.clear();
        } else if (res.statusCode == 404) {
          Fluttertoast.showToast(msg: "User not found");
          invitationController.clear();
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    RememberUserPrefs().checkTokenValidity();
  }

  Widget pendingInvitation(context) {
    return FutureBuilder(
        future: getInvitations(),
        builder: (context, AsyncSnapshot<List<Invitation>> dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dataSnapShot.data == null) {
            return const Center(
              child: Text(
                "No pending requests",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (dataSnapShot.data!.length > 0) {
            return Container(
              height: 150,
              child: ListView.builder(
                itemCount: dataSnapShot.data!.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Invitation eachInvitation = dataSnapShot.data![index];
                  return GestureDetector(
                    onTap: () {
                      //Get.to(ItemDetailScreen(itemInfo: eachClothItemData));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: 150,
                      margin: EdgeInsets.fromLTRB(index == 0 ? 16 : 8, 10,
                          index == dataSnapShot.data!.length - 1 ? 16 : 8, 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                color: Colors.grey)
                          ]),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "From ${eachInvitation.sender.username}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  eachInvitation.team.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.red,
                                      child: InkWell(
                                        onTap: () {
                                          respondInvitation(
                                              eachInvitation.id, false);
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(8),
                                          height: 30,
                                          child: const Text(
                                            "Reject",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.green,
                                      child: InkWell(
                                        onTap: () {
                                          respondInvitation(
                                              eachInvitation.id, true);
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(8),
                                          height: 30,
                                          child: const Text(
                                            "Approve",
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                Center(
                  child: Text(
                    "No requests pending",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Pending Invitations",
                style: TextStyle(
                    color: primary1Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            pendingInvitation(context),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Teams",
                style: TextStyle(
                    color: primary1Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FutureBuilder(
                future: getTeams(),
                builder: (context, AsyncSnapshot<List<Team>> dataSnapShot) {
                  if (dataSnapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (dataSnapShot.data == null) {
                    return const Center(
                      child: Text(
                        "No teams found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (dataSnapShot.data!.length > 0) {
                    return ListView.builder(
                      itemCount: dataSnapShot.data!.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        Team eachTeam = dataSnapShot.data![index];

                        return GestureDetector(
                          onTap: () {
                            print(eachTeam.id);
                            Get.to(TeamScreen());
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 90,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 20, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: primary1Color,
                                  boxShadow: const [
                                    BoxShadow(
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                        color: Colors.grey)
                                  ],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eachTeam.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          eachTeam.creator,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        customButton: const Icon(
                                          Icons.menu,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        items: items
                                            .map((String item) =>
                                                DropdownMenuItem(
                                                  value: item,
                                                  child: Icon(
                                                    icons[items.indexOf(item)],
                                                    size: 20,
                                                    color: colors[
                                                        items.indexOf(item)],
                                                  ),
                                                ))
                                            .toList(),
                                        value: selectedValue,
                                        onChanged: (String? value) {
                                          if (value == "Update") {
                                            Get.to(const AddTeamScreen(),
                                                arguments: {
                                                  'id': eachTeam.id,
                                                  'name': eachTeam.name,
                                                });
                                          } else if (value == "Share") {
                                            sendInvitation(eachTeam.id);
                                          } else {
                                            deleteTeam(eachTeam.id);
                                          }
                                        },
                                        buttonStyleData: const ButtonStyleData(
                                          height: 40,
                                          width: 45,
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          offset: const Offset(-10, 0),
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "Empty, No Data",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        onPressed: () {
          Get.to(const AddTeamScreen());
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
