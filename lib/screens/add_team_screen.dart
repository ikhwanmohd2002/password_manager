import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/model/team.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({super.key});

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  CurrentUser currentUser = Get.put(CurrentUser());

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();

  addTeam() async {
    Team teamModel = Team(
      1,
      nameController.text.trim(),
      null,
      currentUser.user.username,
    );

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.post(Uri.parse(API.teamInfoIntelliVault),
          headers: {'Authorization': 'Token $token'}, body: teamModel.toJson());

      if (res.statusCode == 201) {
        Fluttertoast.showToast(msg: "Added team");
        setState(() {
          nameController.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments(), arguments: 3);
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  updateTeam(int id) async {
    Team teamModel = Team(
      id,
      nameController.text.trim(),
      null,
      currentUser.user.username,
    );

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.put(Uri.parse("${API.teamInfoIntelliVault}$id/"),
          headers: {'Authorization': 'Token $token'}, body: teamModel.toJson());

      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "Updated team");
        setState(() {
          nameController.clear();
        });
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.to(DashboardOfFragments(), arguments: 3);
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    final int? id = hasArguments ? arguments['id'] : null;
    final String? name = hasArguments ? arguments['name'] : null;
    nameController = TextEditingController(text: name ?? "");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text(hasArguments ? "Update Team" : "Add Team"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                      duration: const Duration(milliseconds: 1800),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: primary1Color))),
                              child: TextFormField(
                                controller: nameController,
                                validator: (value) => value == ""
                                    ? "Please enter team name"
                                    : null,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Team Name",
                                    hintStyle:
                                        TextStyle(color: Colors.grey[700])),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: InkWell(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            if (hasArguments) {
                              updateTeam(id!);
                            } else {
                              addTeam();
                            }
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                primary2Color,
                                primary1Color,
                              ])),
                          child: const Center(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
