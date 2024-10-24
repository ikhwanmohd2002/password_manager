import 'package:flutter/material.dart';
import 'package:password_manager/constants/constant.dart';

class VaultFragmentScreen extends StatefulWidget {
  const VaultFragmentScreen({super.key});

  @override
  State<VaultFragmentScreen> createState() => _VaultFragmentScreenState();
}

class _VaultFragmentScreenState extends State<VaultFragmentScreen> {
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
            Container(
              height: 150,
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding:
                  EdgeInsetsDirectional.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                  color: primary1Color,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Social Media",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Spacer(),
                      Text(
                        "Last Updated : 28/7/2024",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    "Ikhwan",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "17 Items",
                    style: TextStyle(color: Colors.white, fontSize: 21),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showSearchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: TextField(
        style: const TextStyle(color: Colors.black),
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
            hintText: "Search all vaults",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: IconButton(
              onPressed: () {
                //getPassword(searchController.text);
                setState(() {});
              },
              icon: Icon(Icons.search, color: primary1Color),
            )),
      ),
    );
  }
}
