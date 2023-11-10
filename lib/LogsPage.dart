import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:OpenshockCompanion/settings_page.dart' show SettingsPage;
class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final shockerId = prefs.getString('shockerId');

    if (apiKey == null || shockerId == null) {
      // Handle missing API key or shockerId
      return;
    }

    final url = 'https://api.shocklink.net/1/shockers/$shockerId/logs?offset=0&limit=30';

    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
      'OpenShockToken': apiKey,
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['data'] != null) {
        setState(() {
          logs = List<Map<String, dynamic>>.from(jsonData['data']);
        });
      }
    } else {
      // Handle API request error
    }
  }

  Future<void> _handleRefresh() async {
    await fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Scrollbar(
          thumbVisibility: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Logs'),
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Intensity')),
                        DataColumn(label: Text('Duration (s)')),
                      ],
                      rows: logs.map((log) {
                        final controlledBy = log['controlledBy'] as Map<String, dynamic>?;

                        // Add null check for controlledBy
                        if (controlledBy != null) {
                          final name = controlledBy['name'] as String?;
                          final intensity = log['intensity'] as int?;
                          final duration = (log['duration'] as int?)! / 1000; // Convert to seconds

                          // Add null checks for name and intensity
                          if (name != null && intensity != null) {
                            return DataRow(
                              cells: [
                                DataCell(Text(name)),
                                DataCell(Text(intensity.toString())),
                                DataCell(Text(duration.toString())),
                              ],
                            );
                          }
                        }

                        return const DataRow(cells: []);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Logs',
          ),
        ],
        currentIndex: 2, // Set the current index to 2 for the Logs page
        onTap: (index) {
          if (index == 0) {
            // Navigate back to the main page
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            // Navigate to the Settings page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 211, 187, 255), // or any color you prefer
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
