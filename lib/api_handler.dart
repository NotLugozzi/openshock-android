// settings_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController shockerIdController = TextEditingController();

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(labelText: 'API Key'),
            ),
            TextField(
              controller: shockerIdController,
              decoration: const InputDecoration(labelText: 'Shocker ID'),
            ),
            ElevatedButton( // Updated from RaisedButton to ElevatedButton
              child: const Text('Save and Login'),
              onPressed: () {
                saveSettings(apiKeyController.text, shockerIdController.text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveSettings(String apiKey, String shockerId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('apiKey', apiKey);
  await prefs.setString('shockerId', shockerId);
}

Future<void> sendApiRequest(int intensity, int time, int type) async {
  // Fetch saved information from SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Replace these default values with your actual default values or handle accordingly
  final String apiLink = prefs.getString('apiLink') ?? 'https://api.shocklink.net/1/shockers/control';
  final String apiKey = prefs.getString('apiKey') ?? '';
  final String shockerId = prefs.getString('shockerId') ?? '';

  // Build the request body
  final List<Map<String, dynamic>> requestBody = [
    {
      "id": shockerId,
      "type": type,
      "intensity": intensity,
      "duration": time * 1000, // Convert time to milliseconds
    }
  ];

  // Build the headers
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'OpenShockToken': apiKey,
  };

  // Make the API request
  final response = await http.post(
    Uri.parse(apiLink),
    headers: headers,
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    // Request successful, handle the response if needed
    print('API request successful');
    print(response.body);
  } else {
    // Request failed, handle the error
    print('API request failed');
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}