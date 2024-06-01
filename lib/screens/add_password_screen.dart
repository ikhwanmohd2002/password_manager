import 'package:flutter/material.dart';
import 'package:password_manager/constants/constant.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text("Add Password"),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 28),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
