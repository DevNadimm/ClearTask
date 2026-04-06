import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clear_task/data/models/user_profile_model.dart';
import 'package:clear_task/data/repositories/wallet_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserStatsRepository {
  // Singleton pattern for global access to the same stream
  static final UserStatsRepository _instance = UserStatsRepository._internal();
  factory UserStatsRepository() => _instance;
  UserStatsRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for Level-up notifications
  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get levelUpStream => _levelUpController.stream;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference get _profileRef {
    if (_uid == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(_uid).collection('profile').doc('data');
  }

  /// Stream of user profile updates for real-time UI
  Stream<UserProfileModel?> getUserProfileStream() {
    if (_uid == null) return Stream.value(null);
    return _profileRef.snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// Update XP and handle level-ups. Returns true if leveled up.
  Future<bool> addXp(int amount) async {
    try {
      if (_uid == null) {
        debugPrint('⚠️ XP skipped because user is not logged in.');
        return false;
      }
      final doc = await _profileRef.get();
      if (!doc.exists) {
        debugPrint('⚠️ User profile doc not found.');
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;
      int currentXp = data['xp'] ?? 0;
      int currentLevel = data['level'] ?? 1;
      
      int newXp = currentXp + amount;
      int newLevel = (newXp / 100).floor() + 1;
      String newRank = _getRankForLevel(newLevel);

      bool leveledUp = newLevel > currentLevel;

      await _profileRef.update({
        'xp': newXp,
        'level': newLevel,
        'rankTitle': newRank,
      });
      
      debugPrint('⬆️ XP Added: +$amount (Total: $newXp, Level: $newLevel)');

      if (leveledUp) {
        _levelUpController.add(newLevel);
        debugPrint('🎊 LEVEL UP! New Level: $newLevel');
        
        // Award 25 Coins Level Up Bonus
        debugPrint('🎁 Awarding 25 Coins Level Up Bonus');
        await WalletRepository().addCoins(_uid!, 25);
      }

      return leveledUp;
    } catch (e) {
      debugPrint('❌ Error updating XP: $e');
      return false;
    }
  }

  String _getRankForLevel(int level) {
    if (level <= 5) return 'Starter';
    if (level <= 10) return 'Rising';
    if (level <= 20) return 'Doer';
    if (level <= 50) return 'Achiever';
    return 'Legend';
  }

  /// Visual celebration for completing daily goal (no XP to prevent farming).
  Future<void> awardDailyBonus() async {
    // XP reward removed as per user request to prevent "once-per-lifetime" bypass.
    debugPrint('🎉 Daily Goal completed! (Visual-only celebration)');
  }

  /// Award 10 XP once per day when the app starts. Returns true if awarded.
  Future<bool> checkAndAwardLoginBonus() async {
    try {
      if (_uid == null) return false;
      
      final doc = await _profileRef.get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final String? lastBonusDate = data['lastLoginBonusDate'];
      final String today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

      if (lastBonusDate == today) {
        debugPrint('ℹ️ Daily login bonus already awarded for today ($today).');
        return false;
      }

      debugPrint('🎁 Awarding 10 XP Daily Login Bonus for $today');
      
      // Award XP
      await addXp(10);
      
      // Update the date in Firestore
      await _profileRef.update({
        'lastLoginBonusDate': today,
      });
      
      return true;
    } catch (e) {
      debugPrint('❌ Error awarding login bonus: $e');
      return false;
    }
  }

  void dispose() {
    _levelUpController.close();
  }
}
