// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart';
import 'app_state.dart';
import 'LogsPage.dart';
import 'package:provider/provider.dart';
import 'netcheck.dart' show NetCheck, runChecks;

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
    intensityLimitController.text = prefs.getString('intensityLimit') ?? '100';
    durationLimitController.text = prefs.getString('durationLimit') ?? '30';
    // await NetCheck.runChecks();
    Navigator.pop(context);
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
              'App Version: 0.2-beta5 - Build Date: Nov. 13, 2023\n'
              'This application is in no way, shape, or form affiliated with the openshock team.\n'
              '(C) Mercury -as- olbiaphlee 2023. Reproduction and modification is allowed in accordance with the license found in the app\'s git ',
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
