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
    await pref.setBool(_firstTimeKey, false);
  }

  // ── AI Credit Cache ─────────────────────────────────────────────────────────
  static const String _creditBalanceKey = "credit_balance";
  static const String _creditTotalSpentKey = "credit_total_spent";
  static const String _creditLastGrantKey = "credit_last_grant";

  Future<Map<String, dynamic>?> getCachedCredit() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey(_creditBalanceKey)) return null;

    return {
      'balance': pref.getInt(_creditBalanceKey) ?? 0,
      'totalSpent': pref.getInt(_creditTotalSpentKey) ?? 0,
      'lastDailyGrant': pref.getString(_creditLastGrantKey),
    };
  }

  Future<void> setCachedCredit(int balance, int totalSpent, String? lastDailyGrant) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_creditBalanceKey, balance);
    await pref.setInt(_creditTotalSpentKey, totalSpent);
    if (lastDailyGrant != null) {
      await pref.setString(_creditLastGrantKey, lastDailyGrant);
    }
  }

  Future<void> clearCachedCredit() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_creditBalanceKey);
    await pref.remove(_creditTotalSpentKey);
    await pref.remove(_creditLastGrantKey);
  }
}