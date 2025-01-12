// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:password_manager/api_connection/api_connection.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/model/passwordAnalysis.dart';
import 'package:password_manager/user_preferences/userPreferences.dart';

class PasswordHealthAnalysis extends StatefulWidget {
  const PasswordHealthAnalysis({super.key});

  @override
  State<PasswordHealthAnalysis> createState() => _PasswordHealthAnalysisState();
}

class _PasswordHealthAnalysisState extends State<PasswordHealthAnalysis> {
  PasswordAnalysis? analysisData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPasswordAnalysis();
  }

  Future<void> fetchPasswordAnalysis() async {
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.get(
        Uri.parse(
            "${API.checkPasswordIntelliVault}api/password-analysis/latest_analysis/"),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          analysisData = PasswordAnalysis.fromJson(json.decode(response.body));
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("An error occurred")),
      // );
    }
  }

  Future<void> fetchNewPasswordAnalysis() async {
    try {
      String? token = await RememberUserPrefs.readToken();
      final response = await http.post(
        Uri.parse(
            "${API.checkPasswordIntelliVault}api/password-analysis/analyze_passwords/"),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          analysisData = PasswordAnalysis.fromJson(json.decode(response.body));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load new password analysis")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }
  }

  int calculateHealth() {
    List<Issue> issues = analysisData!.issues;
    final Set<String> uniqueUsernames = {}; // Track unique usernames
    double totalIssues = 0;
    if (analysisData!.totalLoginInfos == 0) return 0;

    for (final issue in issues) {
      if (uniqueUsernames.contains(issue.loginUsername)) {
      } else {
        // Unique username, add 1 and mark it as seen
        uniqueUsernames.add(issue.loginUsername);
        totalIssues += 1;
      }
    }
    double score =
        100 - ((totalIssues / analysisData!.totalLoginInfos.toDouble()) * 100);

    return score.clamp(0, 100).toInt(); // Clamp score between 0 and 100
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Analysis"),
        backgroundColor: primary1Color,
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (analysisData == null)
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.vpn_key_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Oh no, no passwords are analyzed!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Analyze passwords to get password health!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            fetchNewPasswordAnalysis();
                          },
                          child: const Text("Analyze Password Health"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      // Password Health Score
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: calculateHealth() /
                                  100, // Replace with dynamic value if available
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  getHealthColor(calculateHealth())),
                            ),
                            Center(
                              child: Text(
                                calculateHealth().toString(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center, // Center-align the text
                          children: [
                            const Text(
                              "OUT OF 100",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            Positioned(
                              right:
                                  90, // Position the refresh button slightly to the side
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                onPressed: () {
                                  fetchNewPasswordAnalysis();
                                }, // Add your refresh function here
                                tooltip: "Refresh analysis",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Summary Grid
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 5,
                          childAspectRatio: 2.3,
                        ),
                        children: [
                          _buildSummaryCard(
                            "Total passwords",
                            analysisData!.totalLoginInfos.toString(),
                            Colors.green,
                          ),
                          _buildSummaryCard(
                            "Breached",
                            analysisData!.breachedPasswordsCount.toString(),
                            Colors.red,
                          ),
                          _buildSummaryCard(
                            "Similar",
                            analysisData!.similarPasswordsCount.toString(),
                            Colors.amber,
                          ),
                          _buildSummaryCard(
                            "Reused",
                            analysisData!.reusedPasswordsCount.toString(),
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Weak Passwords Section
                      if (analysisData!.issues.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Affected Passwords",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...analysisData!.issues.map<Widget>((Issue issue) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                  leading: Icon(
                                    issue.issueType == "similar"
                                        ? Icons.warning
                                        : issue.issueType == "breached"
                                            ? Icons.error
                                            : Icons
                                                .repeat, // Icon for reused passwords
                                    color: issue.issueType == "similar"
                                        ? Colors.yellow
                                        : issue.issueType == "breached"
                                            ? Colors.red
                                            : Colors
                                                .blue, // Color for reused passwords
                                    size: 32,
                                  ),
                                  title: Text(
                                    issue.loginUsername,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    issue.issueType == "similar"
                                        ? "Similarity Score: ${issue.similarityScore?.toStringAsFixed(2)}%"
                                        : issue.issueType == "breached"
                                            ? "Times Exposed: ${issue.details["times_exposed"]}"
                                            : "Reused in: ${issue.details["reused_in"].join(", ")}\nReuse Count: ${issue.details["reuse_count"]}", // Details for reused issue
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      // Action for trailing button
                                    },
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent overflow
                    maxLines: 2, // Limit to one line
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getHealthColor(int healthScore) {
    if (healthScore >= 80) {
      return Colors.green; // Excellent health
    } else if (healthScore >= 50) {
      return Colors.orange; // Moderate health
    } else {
      return Colors.red; // Poor health
    }
  }
}
