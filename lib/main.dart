import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkToken() async {
    try {
      String? token = await RememberUserPrefs.readToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      var res1 = await http.get(
        Uri.parse(API.userDetailsIntelliVault),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        },
      );

      if (res1.statusCode == 200) {
        return true;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Token Expired");
      return false;
    }
    return false;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: false, fontFamily: GoogleFonts.poppins().fontFamily),
      home: FutureBuilder<bool>(
        builder: (context, dataSnapShot) {
          if (dataSnapShot.data == false) {
            return const LoginScreen();
          } else {
            return DashboardOfFragments();
          }
        },
        future: checkToken(),
      ),
    );
  }
}
