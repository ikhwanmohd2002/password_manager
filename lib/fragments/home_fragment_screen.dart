import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/screens/add_password_screen.dart';

class HomeFragmentScreen extends StatefulWidget {
  const HomeFragmentScreen({super.key});

  @override
  State<HomeFragmentScreen> createState() => _HomeFragmentScreenState();
}

class _HomeFragmentScreenState extends State<HomeFragmentScreen> {
  TextEditingController searchController = TextEditingController();
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
            showSearchBarWidget(),
            const SizedBox(
              height: 24,
            ),
            Center(
              child: Text("No Passwords Available"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddPasswordScreen());
        },
        backgroundColor: primary1Color,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget showSearchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        controller: searchController,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary1Color)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary2Color)),
            border: OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: primary2Color)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  searchController.clear();
                });
              },
              icon: Icon(
                Icons.clear,
                color: primary1Color,
              ),
            ),
            hintText: "Search all items",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: IconButton(
              onPressed: () {
                //Get.to(SearchItems(typedKeyWords: searchController.text));
              },
              icon: Icon(Icons.search, color: primary1Color),
            )),
      ),
    );
  }
}
