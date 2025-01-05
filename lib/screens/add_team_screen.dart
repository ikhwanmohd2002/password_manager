import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/controllers/navigation_controller.dart';
import 'package:password_manager/model/team.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

class Add1TeamScreen extends StatefulWidget {
  const Add1TeamScreen({super.key});

  @override
  State<Add1TeamScreen> createState() => _Add1TeamScreenState();
}

class _Add1TeamScreenState extends State<Add1TeamScreen> {
  CurrentUser currentUser = Get.put(CurrentUser());
  final NavigationController navController = Get.find();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  addTeam() async {
    Team teamModel = Team(
        id: 1,
        name: nameController.text.trim(),
        creator: currentUser.user.username);

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.post(Uri.parse(API.teamInfoIntelliVault),
          headers: {'Authorization': 'Token $token'}, body: teamModel.toJson());

      if (res.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Team added successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        nameController.clear();

        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add team."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  updateTeam(int id) async {
    Team teamModel = Team(
        id: id,
        name: nameController.text.trim(),
        creator: currentUser.user.username);

    try {
      String? token = await RememberUserPrefs.readToken();
      var res = await http.put(Uri.parse("${API.teamInfoIntelliVault}$id/"),
          headers: {'Authorization': 'Token $token'}, body: teamModel.toJson());

      if (res.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Team updated successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      } else if (res.statusCode == 404) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Only team admins can update team"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(milliseconds: 2000), () {
          Get.back(result: 'refresh');
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update team."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final hasArguments = Get.arguments != null;
    final arguments = hasArguments ? Get.arguments : {};
    final int? id = hasArguments ? arguments['id'] : null;
    final String? name = hasArguments ? arguments['name'] : null;
    nameController.text = name ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text(hasArguments ? "Update Team" : "Add Team"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasArguments ? "Update your team details" : "Create a new team",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary1Color,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: TextFormField(
                controller: nameController,
                validator: (value) =>
                    value!.isEmpty ? "Please enter a team name" : null,
                decoration: InputDecoration(
                  labelText: "Team Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Enter your team name",
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primary1Color, // Replace `primary` with `backgroundColor`
                foregroundColor:
                    Colors.white, // Replace `onPrimary` with `foregroundColor`
                minimumSize:
                    const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (hasArguments) {
                    updateTeam(id!);
                  } else {
                    addTeam();
                  }
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
