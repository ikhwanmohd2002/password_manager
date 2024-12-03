// ignore_for_file: file_names

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/model/user.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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

  static Future<void> storeLocation(double lat, double lon) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble("lat", lat);
    await preferences.setDouble("lon", lon);
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

  static Future<List<double>?> readLocation() async {
    List<double> location = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    double? lat = preferences.getDouble("lat");
    double? lon = preferences.getDouble("lon");
    if (lat != null && lon != null) {
      location.add(lat);
      location.add(lon);
      return location;
    } else {
      return null;
    }
  }

  static Future<User?> removeUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
    return null;
  }

  static Future<User?> removeToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("token");
    return null;
  }

  static Future<User?> removeLocation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("lat");
    await preferences.remove("lon");
    return null;
  }

  Future<void> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<Position> getCurrentLocation() async {
    await _requestPermission();

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  checkTokenValidity() async {
    try {
      String? token = await RememberUserPrefs.readToken();
      print(token);
      if (token == null || token.isEmpty) {
        Get.off(LoginScreen());
      }
      var res1 = await http.get(
        Uri.parse(API.userDetailsIntelliVault),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token'
        },
      );

      if (res1.statusCode == 200) {
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Token Expired");
      Get.off(LoginScreen());
    }
    Get.off(LoginScreen());
  }
}
