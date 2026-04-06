import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clear_task/data/models/user_wallet_model.dart';
import 'package:flutter/foundation.dart';

class WalletFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get wallet data for a specific user
  /// Returns null if wallet doesn't exist yet (e.g. during signup initialization)
  Future<UserWalletModel?> getWallet(String userId) async {
    try {
      final docRef = _usersCollection.doc(userId).collection('wallet').doc('data');
      final doc = await docRef.get();

      if (doc.exists) {
        return UserWalletModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      // Don't auto-create — let AuthService._initializeUserData handle it
      debugPrint('ℹ️ Wallet document not found for user $userId. Waiting for initialization.');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching wallet: $e');
      rethrow;
    }
  }

  /// Initialize or update wallet data
  Future<void> updateWallet(String userId, UserWalletModel wallet) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('wallet')
          .doc('data')
          .set(wallet.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error updating wallet: $e');
      rethrow;
    }
  }

  /// Claim daily reward transactionally to ensure it only happens once per day.
  /// Uses string date 'YYYY-MM-DD' for comparison.
  Future<bool> claimDailyReward(String userId) async {
    final docRef = _usersCollection.doc(userId).collection('wallet').doc('data');

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        final now = DateTime.now();
        final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final lastRewardDate = data['lastDailyRewardDate'] as String?;

          if (lastRewardDate == todayStr) {
            // Already claimed today
            return false;
          }

          // Update existing
          transaction.update(docRef, {
            'coins': FieldValue.increment(15),
            'totalEarned': FieldValue.increment(15),
            'lastDailyRewardDate': todayStr,
          });
        } else {
          // If document doesn't exist, wait for initializeUserData to create it with 45 coins
          return false;
        }
        return true;
      });
    } catch (e) {
      debugPrint('❌ Error claiming daily reward: $e');
      return false;
    }
  }

  /// Spend coins with a check to prevent negative balances
  Future<bool> spendCoins(String userId, int amount) async {
    final docRef = _usersCollection.doc(userId).collection('wallet').doc('data');

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) return false;

        final data = snapshot.data() as Map<String, dynamic>;
        final currentCoins = data['coins'] as int? ?? 0;

        if (currentCoins < amount) return false;

        transaction.update(docRef, {
          'coins': FieldValue.increment(-amount),
          'totalSpent': FieldValue.increment(amount),
        });

        return true;
      });
    } catch (e) {
      debugPrint('❌ Error spending coins: $e');
      return false;
    }
  }

  /// Add coins (e.g. from ads)
  Future<void> addCoins(String userId, int amount) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('wallet')
          .doc('data')
          .update({
        'coins': FieldValue.increment(amount),
        'totalEarned': FieldValue.increment(amount),
      });
    } catch (e) {
      // If document doesn't exist, Create it
      if (e is FirebaseException && e.code == 'not-found') {
        await _usersCollection.doc(userId).collection('wallet').doc('data').set({
          'coins': amount,
          'totalSpent': 0,
          'totalEarned': amount,
          'lastDailyRewardDate': null,
        });
      } else {
        debugPrint('❌ Error adding coins: $e');
        rethrow;
      }
    }
  }
}
