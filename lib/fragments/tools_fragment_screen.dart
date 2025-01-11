import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:password_manager/constants/constant.dart';
import 'package:password_manager/screens/breach_check_screen.dart';
import 'package:password_manager/screens/password_analysis_screen.dart';
import 'package:password_manager/screens/password_generation_screen.dart';
import 'package:password_manager/screens/phishing_screen.dart';
import 'package:password_manager/screens/similarity_check_screen.dart';

class ToolsFragmentScreen extends StatefulWidget {
  const ToolsFragmentScreen({super.key});

  @override
  State<ToolsFragmentScreen> createState() => _ToolsFragmentScreenState();
}

class _ToolsFragmentScreenState extends State<ToolsFragmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        automaticallyImplyLeading: false,
        backgroundColor: primary1Color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildToolCard('Health Analysis', Icons.health_and_safety,
                PasswordHealthAnalysis()),
            _buildToolCard(
                'Breach Check', Icons.security, const BreachCheckScreen()),
            _buildToolCard(
                'Similarity Check', Icons.compare, SimilarityCheckScreen()),
            _buildToolCard('Phishing', Icons.phishing, const PhishingScreen()),
            _buildToolCard('Password Generation', Icons.vpn_key,
                const PasswordGenerationScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(String title, IconData icon, StatefulWidget? nav) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (nav != null) {
            Get.to(nav);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
