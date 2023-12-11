import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'app_state.dart';
import 'bottom_bar.dart';
import 'settings_page.dart';

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
    final logvalue = prefs.getDouble('logsSharedPreferenceKey') ?? 30;

    if (apiKey == null || shockerId == null) {
      // fuck you i dont handle missing stuff
      return;
    }

    final url =
        'https://api.shocklink.net/1/shockers/$shockerId/logs?offset=0&limit=40';

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
      // Fuck you im not handling errors either
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
    appState.currentIndex = 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 10,
              dataRowMaxHeight: 50,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Intensity')),
                DataColumn(label: Text('Duration')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Time')),
              ],
              rows: logs.map((log) {
                final controlledBy =
                    log['controlledBy'] as Map<String, dynamic>?;
                if (controlledBy != null) {
                  final name = getDisplayName(controlledBy);
                  final intensity = log['intensity'] as int?;
                  final duration = (log['duration'] as int?)! / 1000;
                  final type = log['type'] as String?;
                  final createdAt = log['createdOn'] as String?;

                  if (intensity != null && type != null && createdAt != null) {
                    final userTimezone =
                        DateTime.now().timeZoneOffset; // Get user's timezone

                    final utcDateTime = DateTime.parse(createdAt);
                    final localDateTime = utcDateTime
                        .add(userTimezone); // Convert to local timezone

                    final formattedCreatedAt =
                        DateFormat('dd/MM/yy - HH:mm').format(localDateTime);

                    return DataRow(
                      cells: [
                        DataCell(Text(name)),
                        DataCell(Text(intensity.toString())),
                        DataCell(Text(duration.toString())),
                        DataCell(getIconForType(type)),
                        DataCell(Text(formattedCreatedAt)),
                      ],
                    );
                  }
                }
                return const DataRow(cells: []);
              }).toList(),
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
