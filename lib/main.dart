import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import HapticFeedback
import 'package:OpenshockCompanion/settings_page.dart' show SettingsPage;
import 'package:OpenshockCompanion/api_handler.dart' show sendApiRequest;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Fetch isDarkMode from SharedPreferences
      future: getIsDarkMode(),
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data ?? false; // Use false as a default value

        return MaterialApp(
          theme: isDarkMode ? darkTheme : lightTheme,
          home: SliderPage(),
          darkTheme: darkTheme,
          themeMode: ThemeMode.system, // Use ThemeMode.dark for always dark mode, ThemeMode.light for always light mode
        );
      },
    );
  }

  Future<bool> getIsDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }
}

class SliderPage extends StatefulWidget {
  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int intensityValue = 0;
  int timeValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Openshock Companion'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Intensity: $intensityValue'),
            ),
            Slider(
              value: intensityValue.toDouble(),
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  intensityValue = value.round();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Time: $timeValue'),
            ),
            Slider(
              value: timeValue.toDouble(),
              min: 0,
              max: 30,
              onChanged: (value) {
                setState(() {
                  timeValue = value.round();
                });
              },
            ),
            if (intensityValue < 1 || timeValue < 1)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Warning: Intensity and time values must be at least 1',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.flash_on), // Lightning bolt icon
                  label: Text('Shock'),
                  onPressed: () {
                    if (intensityValue < 1 || timeValue < 1) {
                      // Display a warning, no need for a toast
                    } else {
                      HapticFeedback.vibrate(); // Add haptic feedback
                      sendApiRequest(intensityValue, timeValue, 1);
                    }
                  },
                ),
                SizedBox(width: 8.0), // Reduced padding here
                ElevatedButton.icon(
                  icon: Icon(Icons.vibration), // Vibration icon
                  label: Text('Vibrate'),
                  onPressed: () {
                    if (intensityValue < 1 || timeValue < 1) {
                      // Display a warning, no need for a toast
                    } else {
                      HapticFeedback.vibrate(); // Add haptic feedback
                      sendApiRequest(intensityValue, timeValue, 2);
                    }
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: Text('Settings'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Color.fromARGB(221, 63, 63, 63)),
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.deepPurple,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
);
