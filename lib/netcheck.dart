import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class NetCheck {
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
}
