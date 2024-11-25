import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/model/user.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RememberUserPrefs {
  static Future<void> storeUserInfo(User userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode(userInfo.toJson());
    await preferences.setString("currentUser", userJsonData);
  }

  static Future<void> storeToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("token", token);
  }

  static Future<User?> readUserInfo() async {
    User? currentUserInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString("currentUser");
    if (userInfo != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userInfo);
      currentUserInfo = User.fromJson(userDataMap);
    }

    return currentUserInfo;
  }

  static Future<String?> readToken() async {
    String? currentToken;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    currentToken = token;
    return currentToken;
  }

  static Future<User?> removeUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
  }

  static Future<User?> removeToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("token");
  }

  checkTokenValidity() async {
    try {
      String? token = await RememberUserPrefs.readToken();
      print(token);
      if (token == null || token.isEmpty) {
        return const LoginScreen();
      }
      var res1 = await http.get(
        Uri.parse(API.userDetailsIntelliVault),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        },
      );

      if (res1.statusCode == 200) {}
    } catch (e) {
      Fluttertoast.showToast(msg: "Token Expired");
      return const LoginScreen();
    }
    return const LoginScreen();
  }
}
