// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart';
import 'app_state.dart';
import 'LogsPage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController shockerIdController = TextEditingController();
  final TextEditingController intensityLimitController =
      TextEditingController();
  final TextEditingController durationLimitController = TextEditingController();

  bool showApiKey = false;
  bool showShockerId = false;

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
      intensityLimitController.text = prefs.getString('intensityLimit') ?? '';
      durationLimitController.text = prefs.getString('durationLimit') ?? '';
    });
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('apiKey', apiKeyController.text);
    prefs.setString('shockerId', shockerIdController.text);
    await runChecks();

    Navigator.pop(context);
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
      body: Padding(
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
            const Text('Intensity Limit'),
            TextField(
              controller: intensityLimitController,
              decoration: const InputDecoration(
                labelText: 'Intensity Limit',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Duration Limit'),
            TextField(
              controller: durationLimitController,
              decoration: const InputDecoration(
                labelText: 'Duration Limit',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveSettings,
              child: const Text('Save'),
            ),
            const SizedBox(height: 15),
            // Add the new text below the Save button
            const Text(
              'App Version: 0.2-beta6 - Build Date: Nov. 27, 2023\n'
              '(C) Mercury, 2023',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12),
            ),
          ],
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
                MaterialPageRoute(builder: (context) => const LogsPage()),
              );
              appState.currentIndex = 2;
            }
          });
        },
      ),
    );
  }
}
