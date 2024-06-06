import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/fragments/dashboard_of_fragments.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: false, fontFamily: GoogleFonts.poppins().fontFamily),
      home: FutureBuilder(
        builder: (context, dataSnapShot) {
          if (dataSnapShot.data == null) {
            return const LoginScreen();
          } else {
            return DashboardOfFragments();
          }
        },
        future: RememberUserPrefs.readUserInfo(),
      ),
    );
  }
}
