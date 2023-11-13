import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:OpenshockCompanion/settings_page.dart' show SettingsPage;
import 'package:OpenshockCompanion/LogsPage.dart' show LogsPage;
import 'package:OpenshockCompanion/api_handler.dart' show sendApiRequest;
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_bar.dart';
import 'app_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()), // Add this line
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getIsDarkMode(),
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data ?? false;

        return MaterialApp(
          theme: isDarkMode ? darkTheme : lightTheme,
          home: const SliderPage(),
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }

  Future<bool> getIsDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> getLimits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String intensityLimit = prefs.getString('intensityLimit') ?? '';
    final String durationLimit = prefs.getString('durationLimit') ?? '';
  }
}

class SliderPage extends StatefulWidget {
  const SliderPage({Key? key}) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int intensityValue = 1;
  int timeValue = 1;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Openshock Companion'),
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
              min: 1,
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
              min: 1,
              max: 30,
              onChanged: (value) {
                setState(() {
                  timeValue = value.round();
                });
              },
            ),
            if (intensityValue < 1 || timeValue < 1)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Warning: Intensity and time values must be at least 1',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Shock'),
                  onPressed: () {
                    if (intensityValue < 1 || timeValue < 1) {
                      // Display a warning, no need for a toast
                    } else {
                      HapticFeedback.vibrate();
                      sendApiRequest(intensityValue, timeValue, 1);
                      showToast('API request sent');
                    }
                  },
                ),
                const SizedBox(width: 8.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.vibration),
                  label: const Text('Vibrate'),
                  onPressed: () {
                    if (intensityValue < 1 || timeValue < 1) {
                      // Display a warning, no need for a toast
                    } else {
                      HapticFeedback.vibrate();
                      sendApiRequest(intensityValue, timeValue, 2);
                      showToast('API request sent');
                    }
                  },
                ),
              ],
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
              appState.currentIndex = 0; // Reset to home index
              // Home tab
            } else if (index == 1) {
              // Settings tab
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogsPage()),
              );
            }
          });
        },
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
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
