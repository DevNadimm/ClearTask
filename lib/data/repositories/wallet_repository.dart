import 'package:clear_task/data/datasources/preferences_helper.dart';
import 'package:clear_task/data/models/user_wallet_model.dart';
import 'package:clear_task/data/services/wallet_firestore_service.dart';
import 'package:flutter/foundation.dart';

class WalletRepository {
  final WalletFirestoreService _firestoreService = WalletFirestoreService();
  final PreferencesHelper _prefs = PreferencesHelper();

  /// Fetches wallet data, trying cache first for immediate UI response, then syncing with cloud
  Future<UserWalletModel> getWallet(String userId) async {
    // Try to get from cache first
    final cachedData = await _prefs.getCachedWallet();
    UserWalletModel? wallet;

    if (cachedData != null) {
      wallet = UserWalletModel(
        coins: cachedData['coins'],
        totalSpent: cachedData['totalSpent'],
        totalEarned: cachedData['totalEarned'],
        lastDailyRewardDate: cachedData['lastDailyRewardDate'],
      );
    }

    try {
      // Fetch from cloud to ensure sync (handles migration too)
      final cloudWallet = await _firestoreService.getWallet(userId);
      if (cloudWallet != null) {
        // Update cache with cloud data
        await _prefs.setCachedWallet(
          cloudWallet.coins,
          cloudWallet.totalSpent,
          cloudWallet.totalEarned,
          cloudWallet.lastDailyRewardDate,
        );
        return cloudWallet;
      }
    } catch (e) {
      debugPrint('⚠️ Network failure fetching wallet, using cache if available: $e');
    }

    return wallet ?? UserWalletModel.initial();
  }

  /// Claims daily reward if not already granted today
  Future<bool> claimDailyReward(String userId) async {
    final success = await _firestoreService.claimDailyReward(userId);
    if (success) {
      // Refresh cache
      await getWallet(userId);
    }
    return success;
  }

  /// Adds coins (e.g. from ads)
  Future<void> addCoins(String userId, int amount) async {
    await _firestoreService.addCoins(userId, amount);
    // Refresh cache
    await getWallet(userId);
  }

  /// Spends coins
  Future<bool> spendCoins(String userId, int amount) async {
    final success = await _firestoreService.spendCoins(userId, amount);
    if (success) {
      // Refresh cache
      await getWallet(userId);
    }
    return success;
  }

  /// Clears local cache (for logout)
  Future<void> clearCache() async {
    await _prefs.clearCachedWallet();
  }
}
