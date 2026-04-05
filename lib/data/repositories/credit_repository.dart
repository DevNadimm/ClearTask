import 'package:clear_task/data/datasources/preferences_helper.dart';
import 'package:clear_task/data/models/user_credit_model.dart';
import 'package:clear_task/data/services/credit_firestore_service.dart';
import 'package:flutter/foundation.dart';

class CreditRepository {
  final CreditFirestoreService _firestoreService = CreditFirestoreService();
  final PreferencesHelper _prefs = PreferencesHelper();

  /// Fetches credit, trying cache first for immediate UI response, then syncing with cloud
  Future<UserCreditModel> getCredit(String userId) async {
    // Try to get from cache first
    final cachedData = await _prefs.getCachedCredit();
    UserCreditModel? credit;

    if (cachedData != null) {
      // Map to DateTime for lastDailyGrant
      DateTime? lastGrant;
      if (cachedData['lastDailyGrant'] != null) {
        lastGrant = DateTime.parse(cachedData['lastDailyGrant']);
      }

      credit = UserCreditModel(
        balance: cachedData['balance'],
        totalSpent: cachedData['totalSpent'],
        lastDailyGrant: lastGrant,
      );
    }

    try {
      // Fetch from cloud to ensure sync
      final cloudCredit = await _firestoreService.getCredit(userId);
      if (cloudCredit != null) {
        // Update cache with cloud data
        await _prefs.setCachedCredit(
          cloudCredit.balance,
          cloudCredit.totalSpent,
          cloudCredit.lastDailyGrant?.toIso8601String(),
        );
        return cloudCredit;
      }
    } catch (e) {
      debugPrint('⚠️ Network failure fetching credit, using cache if available: $e');
    }

    return credit ?? UserCreditModel.initial();
  }

  /// Grants daily credit if not already granted
  Future<bool> checkAndGrantDaily(String userId) async {
    final success = await _firestoreService.grantDailyCredit(userId);
    if (success) {
      // Sync local cache immediately after successful grant
      await getCredit(userId);
    }
    return success;
  }

  /// Adds credit from ads
  Future<void> addAdReward(String userId, int amount) async {
    await _firestoreService.addCredit(userId, amount);
    // Sync local cache
    await getCredit(userId);
  }

  /// Spends credit
  Future<bool> spend(String userId, int amount) async {
    final success = await _firestoreService.spendCredit(userId, amount);
    if (success) {
      // Sync local cache
      await getCredit(userId);
    }
    return success;
  }

  /// Clears local cache (for logout)
  Future<void> clearCache() async {
    await _prefs.clearCachedCredit();
  }
}
