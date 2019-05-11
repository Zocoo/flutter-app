import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  set(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  get(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(key);
    return value;
  }

  remove(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
