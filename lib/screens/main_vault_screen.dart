import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/constants/constant.dart';

class MainVaultScreen extends StatefulWidget {
  const MainVaultScreen({super.key});

  @override
  State<MainVaultScreen> createState() => _MainVaultScreenState();
}

class _MainVaultScreenState extends State<MainVaultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text("Main Vault"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text("Main Vault Screen"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
    ;
  }
}
