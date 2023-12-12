import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewShareLinkPage extends StatefulWidget {
  const NewShareLinkPage({Key? key}) : super(key: key);

  @override
  _NewShareLinkPageState createState() => _NewShareLinkPageState();
}

class _NewShareLinkPageState extends State<NewShareLinkPage> {
  late TextEditingController linkNameController;
  DateTime? selectedDateTime;
  bool neverExpire = false;
  double durationValue = 0;
  double intensityValue = 0;
  String? shareLink;

  @override
  void initState() {
    super.initState();
    linkNameController = TextEditingController();
  }

  Future<String?> _getApiKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiKey');
  }

  Future<String?> _getShockerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('shockerId');
  }

  Future<void> saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? apiKey = prefs.getString('apiKey');
    final String? shockerId = prefs.getString('shockerId');

    if (apiKey != null && shockerId != null) {
      final String linkName = linkNameController.text;
      final int durationInMilliseconds = (durationValue * 1000).toInt();

      final createLinkResponse = await http.post(
        Uri.parse('https://api.shocklink.net/1/shares/links'),
        headers: {
          'accept': 'application/json',
          'OpenShockToken': apiKey,
        },
        body: jsonEncode({
          'name': linkName,
          'expiresOn': selectedDateTime?.toIso8601String(),
        }),
      );

      if (createLinkResponse.statusCode == 200) {
        final responseData = jsonDecode(createLinkResponse.body);
        final String linkId = responseData['data'];

        final addShockerResponse = await http.put(
          Uri.parse('https://api.shocklink.net/1/shares/links/$linkId/$shockerId'),
          headers: {
            'accept': 'application/json',
            'OpenShockToken': apiKey,
          },
        );

        if (addShockerResponse.statusCode == 200) {
          final setPermissionsResponse = await http.patch(
            Uri.parse('https://api.shocklink.net/1/shares/links/$linkId/$shockerId'),
            headers: {
              'accept': 'application/json',
              'OpenShockToken': apiKey,
            },
            body: jsonEncode({
              'permissions': {
                'vibrate': true,
                'sound': false,
                'shock': true,
              },
              'limits': {
                'intensity': intensityValue,
                'duration': durationInMilliseconds,
              },
              'cooldown': 30000,
            }),
          );

          if (setPermissionsResponse.statusCode == 200) {
            setState(() {
              shareLink = 'https://shockl.ink/s/$linkId';
            });
          } else {
            // Handle failure in setting permissions
          }
        } else {
          // Handle failure in adding shocker to the link
        }
      } else {
        // Handle failure in creating the share link
      }
    } else {
      // Handle missing apiKey or shockerId
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = DateTime(picked.year, picked.month, picked.day,
            selectedDateTime?.hour ?? 0, selectedDateTime?.minute ?? 0);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime?.year ?? DateTime.now().year,
          selectedDateTime?.month ?? DateTime.now().month,
          selectedDateTime?.day ?? DateTime.now().day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Share Link'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Link Name'),
            TextFormField(
              controller: linkNameController,
              decoration: InputDecoration(
                hintText: 'Enter link name',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: neverExpire,
                  onChanged: (value) {
                    setState(() {
                      neverExpire = value!;
                      if (neverExpire) {
                        selectedDateTime = null;
                      }
                    });
                  },
                ),
                const Text('Never Expire'),
              ],
            ),
            if (!neverExpire)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date and Time'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Select Date'),
                      ),
                      TextButton(
                        onPressed: () => _selectTime(context),
                        child: const Text('Select Time'),
                      ),
                      if (selectedDateTime != null)
                        Text(
                          'Selected: ${DateFormat.yMd().add_jm().format(selectedDateTime!)}',
                        ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text('Duration'),
            Slider(
              value: durationValue,
              min: 0,
              max: 30,
              divisions: 30,
              label: durationValue.round().toString(),
              onChanged: (value) {
                setState(() {
                  durationValue = value;
                });
              },
            ),
            Text('Selected Duration: ${durationValue.round()}'),
            const SizedBox(height: 20),
            const Text('Intensity'),
            Slider(
              value: intensityValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: intensityValue.round().toString(),
              onChanged: (value) {
                setState(() {
                  intensityValue = value;
                });
              },
            ),
            Text('Selected Intensity: ${intensityValue.round()}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveSettings();
              },
              child: const Text('Create Share Link'),
            ),
            if (shareLink != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generated Share Link:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: shareLink,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Generated Share Link',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
