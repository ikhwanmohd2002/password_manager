import 'package:flutter/material.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final List<String> teamMembers = ['Alice', 'Bob', 'Charlie', 'Diana'];
  final List<String> vaults = ['Vault 1', 'Vault 2', 'Vault 3'];

  // Primary colors
  final Color primary1Color = Color(0xffF86668);
  final Color primary2Color = Color(0xffF2167B);
  final Color primary3Color = Color(0xfff8484a);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary1Color,
        title: Text('Team Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Members Section
            Text(
              'Team Members',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary1Color),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[200], // Light grey color for cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primary3Color,
                        child: Text(
                          teamMembers[index][0], // First letter of the name
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        teamMembers[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),

            Divider(color: primary3Color, thickness: 2),

            // Vaults Section
            Text(
              'Vaults',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary1Color),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: vaults.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey[200], // Light grey color for cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.lock, color: primary3Color),
                      title: Text(
                        vaults[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMember,
        backgroundColor: primary1Color,
        child: Icon(Icons.add),
        tooltip: 'Add Team Member',
      ),
    );
  }

  // Function to add a new member (example)
  void _addNewMember() {
    setState(() {
      teamMembers.add('New Member ${teamMembers.length + 1}');
    });
  }
}
