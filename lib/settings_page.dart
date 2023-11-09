// settings_page.dart
import 'package:flutter/material.dart';
import 'package:OpenshockCompanion/api_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController shockerIdController = TextEditingController();

  bool showApiKey = false;
  bool showShockerId = false;
  bool isDarkMode = false;

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
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> saveSettingsAndTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('apiKey', apiKeyController.text);
    prefs.setString('shockerId', shockerIdController.text);
    prefs.setBool('isDarkMode', isDarkMode);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Key'),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                suffixIcon: IconButton(
                  icon: Icon(showApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showApiKey = !showApiKey;
                    });
                  },
                ),
              ),
              obscureText: !showApiKey,
            ),
            SizedBox(height: 16),
            Text('Shocker ID'),
            TextField(
              controller: shockerIdController,
              decoration: InputDecoration(
                labelText: 'Shocker ID',
                suffixIcon: IconButton(
                  icon: Icon(showShockerId ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showShockerId = !showShockerId;
                    });
                  },
                ),
              ),
              obscureText: !showShockerId,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Dark Mode'),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Save'),
              onPressed: saveSettingsAndTheme,
            ),
          ],
        ),
      ),
    );
  }
}
