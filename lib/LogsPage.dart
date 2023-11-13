import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart';
import 'app_state.dart';
import 'settings_page.dart';
import 'package:provider/provider.dart';

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
      // fuck you i'm not going to properly handle missing stuff
      return;
    }

    final url =
        'https://api.shocklink.net/1/shockers/$shockerId/logs?offset=0&limit=30';

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
      // fuck you i'm not going to properly handle missing stuff
    }
  }

  Future<void> _handleRefresh() async {
    await fetchLogs();
  }

  Icon getIconForType(String type) {
    print('Type: $type');
    switch (type.toLowerCase()) {
      case 'vibrate':
        return const Icon(Icons.vibration);
      case 'shock':
        return const Icon(Icons.flash_on);
      case 'sound':
        return const Icon(Icons.volume_up);
      default:
        return const Icon(Icons.help);
    }
  }

  String getDisplayName(Map<String, dynamic> controlledBy) {
    final customName = controlledBy['customName'] as String?;
    return customName ?? controlledBy['name'] as String? ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

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
                        DataColumn(label: Text('Type')),
                      ],
                      rows: logs.map((log) {
                        final controlledBy =
                            log['controlledBy'] as Map<String, dynamic>?;
                        if (controlledBy != null) {
                          final name = getDisplayName(controlledBy);
                          final intensity = log['intensity'] as int?;
                          final duration = (log['duration'] as int?)! / 1000;
                          final type = log['type'] as String?;
                          if (intensity != null && type != null) {
                            return DataRow(
                              cells: [
                                DataCell(Text(name)),
                                DataCell(Text(intensity.toString())),
                                DataCell(Text(duration.toString())),
                                DataCell(getIconForType(type)),
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
      bottomNavigationBar: BottomBar(
        currentIndex: appState.currentIndex,
        onTap: (index) {
          appState.currentIndex = index;
          setState(() {
            if (index == 0) {
              appState.currentIndex = 0;
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }
          });
        },
      ),
    );
  }
}
