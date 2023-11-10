// settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
            const SizedBox(height: 16),
            const Text('Shocker ID'),
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
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Dark Mode'),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveSettingsAndTheme,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
