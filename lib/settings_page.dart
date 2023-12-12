import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart';
import 'app_state.dart';
import 'logs_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'NewShareLinkPage.dart'; 

class settings_page extends StatefulWidget {
  const settings_page({Key? key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<settings_page> {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController shockerIdController = TextEditingController();
  final TextEditingController intensityLimitController =
      TextEditingController();
  final TextEditingController durationLimitController = TextEditingController();

  bool showApiKey = false;
  bool showShockerId = false;
  double numberOfLogs = 30; // Default value for the number of logs
  static const String logsSharedPreferenceKey =
      'nlogs'; // Shared preference key

  @override
  void initState() {
    super.initState();
    loadSavedSettings();
  }

  Future<void> loadSavedSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiKeyController.text = prefs.getString('apiKey') ?? '';
      shockerIdController.text = prefs.getString('shockerId') ?? '';
      numberOfLogs = prefs.getDouble(logsSharedPreferenceKey) ?? 30;
    });
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('apiKey', apiKeyController.text);
    prefs.setString('shockerId', shockerIdController.text);
    await runChecks();
    prefs.setDouble(logsSharedPreferenceKey, numberOfLogs);

    Navigator.pop(context);
  }

  Future<String> fetchCommitData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey') ?? '';
    http.Response response = await http.get(
      Uri.parse('https://api.shocklink.net/1'),
      headers: {
        'accept': 'application/json',
        'OpenShockToken': apiKey,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      String commit = responseData['data']['commit'];
      return commit.substring(0, 7); // Extract the first 5 characters
    } else {
      throw Exception('Failed to load version data');
    }
  }

  static Future<void> runChecks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey') ?? '';
    http.Response response1 = await http.get(
      Uri.parse('https://api.shocklink.net/1/shockers/own'),
      headers: {
        'accept': 'application/json',
        'OpenShockToken': apiKey,
      },
    );
    if (response1.statusCode == 200) {
      String shockerId = prefs.getString('shockerId') ?? '';
      http.Response response2 = await http.get(
        Uri.parse('https://api.shocklink.net/1/shockers/$shockerId'),
        headers: {
          'accept': 'application/json',
          'OpenShockToken': apiKey,
        },
      );

      if (response2.statusCode == 200) {
        showSuccessToast('Information is correct');
      } else {
        showToast('Incorrect Shocker ID');
      }
    } else {
      showToast('Incorrect API Key');
    }
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.currentIndex = 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('API Key'),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                suffixIcon: IconButton(
                  icon: Icon(
                      showApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showApiKey = !showApiKey;
                    });
                  },
                ),
              ),
              obscureText: !showApiKey,
            ),
            const SizedBox(height: 16),
            const Text('Shocker ID'),
            TextField(
              controller: shockerIdController,
              decoration: InputDecoration(
                labelText: 'Shocker ID',
                suffixIcon: IconButton(
                  icon: Icon(
                      showShockerId ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showShockerId = !showShockerId;
                    });
                  },
                ),
              ),
              obscureText: !showShockerId,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Logs to be fetched: ${numberOfLogs.toInt()}'),
                Slider(
                  value: numberOfLogs,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (newValue) {
                    setState(() {
                      numberOfLogs = newValue;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveSettings,
              child: const Text('Save'),
            ),
            const SizedBox(height: 15),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewShareLinkPage()),
    );
                },
                child: const Text('New Share Link'),
              ),
              ElevatedButton(
                onPressed: () {

                },
                child: const Text('My Share Links'),
              ),
            ],
          ),
            FutureBuilder<String>(
              future: fetchCommitData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    'App Version: 0.3-rc3 - Build Date: Dec. 11, 2023\n'
                    '(C) Mercury, 2023\n'
                    'Connected to api.shocklink.org, version ${snapshot.data}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 12),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: BottomBar(
        currentIndex: appState.currentIndex,
        onTap: (index) {
          appState.currentIndex = index;
          setState(() {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
              appState.currentIndex = 0;
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const logs_page()),
              );
              appState.currentIndex = 2;
            }
          });
        },
      ),
    );
  }
}
