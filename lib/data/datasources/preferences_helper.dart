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

  // ── Signup Celebration ────────────────────────────────────────────────────
  static const String _justSignedUpKey = "just_signed_up";

  Future<bool> wasJustSignedUp() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_justSignedUpKey) ?? false;
  }

  Future<void> setJustSignedUp(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(_justSignedUpKey, value);
  }

  // ── Wallet Cache ─────────────────────────────────────────────────────────
  static const String _walletCoinsKey = "wallet_coins";
  static const String _walletTotalSpentKey = "wallet_total_spent";
  static const String _walletTotalEarnedKey = "wallet_total_earned";
  static const String _walletLastRewardDateKey = "wallet_last_reward_date";

  Future<Map<String, dynamic>?> getCachedWallet() async {
    final pref = await SharedPreferences.getInstance();
    // Fallback to old key if new key doesn't exist for smooth migration
    if (!pref.containsKey(_walletCoinsKey) && !pref.containsKey('credit_balance')) return null;

    return {
      'coins': pref.getInt(_walletCoinsKey) ?? pref.getInt('credit_balance') ?? 0,
      'totalSpent': pref.getInt(_walletTotalSpentKey) ?? pref.getInt('credit_total_spent') ?? 0,
      'totalEarned': pref.getInt(_walletTotalEarnedKey) ?? pref.getInt('credit_balance') ?? 0,
      'lastDailyRewardDate': pref.getString(_walletLastRewardDateKey),
    };
  }

  Future<void> setCachedWallet(int coins, int totalSpent, int totalEarned, String? lastDailyRewardDate) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_walletCoinsKey, coins);
    await pref.setInt(_walletTotalSpentKey, totalSpent);
    await pref.setInt(_walletTotalEarnedKey, totalEarned);
    if (lastDailyRewardDate != null) {
      await pref.setString(_walletLastRewardDateKey, lastDailyRewardDate);
    }
  }

  Future<void> clearCachedWallet() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_walletCoinsKey);
    await pref.remove(_walletTotalSpentKey);
    await pref.remove(_walletTotalEarnedKey);
    await pref.remove(_walletLastRewardDateKey);
  }
}