import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> vaultItems = [
    {'title': 'Google', 'subtitle': 'yessir'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
    {'title': 'Yes', 'subtitle': 'hdjd'},
  ];

  void _showBottomSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text("View"),
                onTap: () {
                  Navigator.pop(context);
                  // Add view action here
                },
              ),
              ListTile(
                title: Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  // Add edit action here
                },
              ),
              ListTile(
                title: Text("Copy username"),
                onTap: () {
                  Navigator.pop(context);
                  // Add copy username action here
                },
              ),
              ListTile(
                title: Text("Copy password"),
                onTap: () {
                  Navigator.pop(context);
                  // Add copy password action here
                },
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logins'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: vaultItems.length,
                itemBuilder: (context, index) {
                  final item = vaultItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.blueGrey[800],
                    child: ListTile(
                      leading: Icon(Icons.language, color: Colors.white),
                      title: Text(
                        item['title']!,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        item['subtitle']!,
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () =>
                            _showBottomSheet(context, item['title']!),
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
        onPressed: () {
          // Add action for new vault item
        },
        backgroundColor: Colors.blueGrey[900],
        child: Icon(Icons.add),
      ),
    );
  }
}
