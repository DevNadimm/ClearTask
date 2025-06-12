import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  final String _firstTimeKey = "isFirstTime";

  Future<bool> isFirstTimeUser () async {
    final pref = await SharedPreferences.getInstance();
    final bool? isFirstTime = pref.getBool(_firstTimeKey);
    return isFirstTime ?? true;
  }

  Future<void> setUserVisited () async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool(_firstTimeKey, false);
  }
}