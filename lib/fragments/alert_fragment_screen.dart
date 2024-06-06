import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/fragments/shared_fragment_screen.dart';
import 'package:password_manager/model/alert.dart';
import 'package:password_manager/user_preferences/current_user.dart';
import 'package:http/http.dart' as http;

class AlertFragmentScreen extends StatefulWidget {
  const AlertFragmentScreen({super.key});

  @override
  State<AlertFragmentScreen> createState() => _AlertFragmentScreenState();
}

class _AlertFragmentScreenState extends State<AlertFragmentScreen> {
  final currentOnlineUser = Get.put(CurrentUser());
  List<RxBool> isResolved = [];

  String formatDateTime(String date) {
    DateTime tempDate = DateFormat("yyyy-MM-dd hh:mm:ss").parse(date);
    String dateReal = DateFormat("dd MMM hh:mm").format(tempDate);
    return dateReal;
  }

  updateStatus(int alert_id, bool isResolved) async {
    try {
      var res = await http.post(Uri.parse(API.updateAlert), body: {
        'alert_id': alert_id.toString(),
        'status': isResolved ? "resolved" : "new"
      });

      if (res.statusCode == 200) {
        var resBodyOfUpdateStatus = await jsonDecode(res.body);
        if (resBodyOfUpdateStatus['success'] == true) {
        } else {
          Fluttertoast.showToast(msg: "An error has occured, try again");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  Future<List<Alert>> getCurrentUserAlert() async {
    List<Alert> alertListOfCurrentUser = [];
    try {
      var res = await http.post(Uri.parse(API.readAlert),
          body: {"user_id": currentOnlineUser.user.user_id.toString()});

      if (res.statusCode == 200) {
        var responseBodyOfReadAlert = jsonDecode(res.body);
        if (responseBodyOfReadAlert['success'] == true) {
          (responseBodyOfReadAlert['currentUserAlertData'] as List)
              .forEach((eachCurrentUserAlertData) {
            alertListOfCurrentUser
                .add(Alert.fromJson(eachCurrentUserAlertData));
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Error occured executing query");
      }
    } catch (errorMsg) {
      print(errorMsg);
    }

    return alertListOfCurrentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [alertListItemDesignWidget(context)],
        ),
      ),
    );
  }

  alertListItemDesignWidget(context) {
    return FutureBuilder(
        future: getCurrentUserAlert(),
        builder: (context, AsyncSnapshot<List<Alert>> dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (dataSnapShot.data == null) {
            return const Center(
              child: Text(
                "No alert found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          if (dataSnapShot.data!.length > 0) {
            return ListView.builder(
              itemCount: dataSnapShot.data!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                Alert eachAlertItemRecord = dataSnapShot.data![index];
                if (eachAlertItemRecord.status == "new") {
                  isResolved.add(false.obs);
                } else {
                  isResolved.add(true.obs);
                }

                return GestureDetector(
                  onTap: () {
                    //Get.to(ItemDetailScreen(itemInfo: clickedClothItem));
                    if (eachAlertItemRecord.type == "shared_password") {
                      Get.to(SharedFragmentScreen());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.fromLTRB(16, index == 0 ? 16 : 8, 16,
                        index == dataSnapShot.data!.length - 1 ? 16 : 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              offset: Offset(0, 3),
                              blurRadius: 6,
                              color: Colors.grey)
                        ]),
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    eachAlertItemRecord.type! ==
                                            "shared_password"
                                        ? "Shared Password"
                                        : "Security",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, right: 12),
                                    child: Text(
                                      formatDateTime(eachAlertItemRecord
                                          .dateTime
                                          .toString()),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eachAlertItemRecord.description
                                          .toString()
                                          .replaceAll("[", "")
                                          .replaceAll("]", ""),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Obx(() => IconButton(
                                      onPressed: () {
                                        isResolved[index].value =
                                            !isResolved[index].value;

                                        updateStatus(
                                            eachAlertItemRecord.alert_id!,
                                            isResolved[index].value);
                                      },
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: isResolved[index].value
                                            ? Colors.green
                                            : Colors.red,
                                      ))),
                                ],
                              )
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No Alerts",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
        });
  }
}
