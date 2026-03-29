import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages premium status, AI usage tracking, weekly resets, and Firestore sync.
class PremiumService {
  static const int maxFreeUsesPerWeek = 4;

  // SharedPreferences keys
  static const String _keyWeeklyUsage = 'aiWeeklyUsage';
  static const String _keyBonusUses = 'aiBonusUses';
  static const String _keyWeekStart = 'aiWeekStart';

  // ── Usage tracking ────────────────────────────────────────────────────────

  Future<int> getWeeklyUsageCount() async {
    await _checkWeeklyReset();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWeeklyUsage) ?? 0;
  }

  Future<int> getBonusUses() async {
    await _checkWeeklyReset();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBonusUses) ?? 0;
  }

  /// Total uses available = max free + bonus - used
  Future<int> getRemainingUses() async {
    final used = await getWeeklyUsageCount();
    final bonus = await getBonusUses();
    final total = maxFreeUsesPerWeek + bonus;
    return (total - used).clamp(0, total);
  }

  Future<bool> canUseAi() async {
    return (await getRemainingUses()) > 0;
  }

  Future<void> incrementUsage() async {
    await _checkWeeklyReset();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyWeeklyUsage) ?? 0;
    await prefs.setInt(_keyWeeklyUsage, current + 1);
    await _syncToFirestore();
  }

  Future<void> grantBonusUses(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyBonusUses) ?? 0;
    await prefs.setInt(_keyBonusUses, current + count);
    await _syncToFirestore();
  }

  // ── Weekly reset ──────────────────────────────────────────────────────────

  /// Returns the Monday 00:00 of the current ISO week.
  DateTime _currentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  Future<void> _checkWeeklyReset() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMs = prefs.getInt(_keyWeekStart);
    final currentMs = _currentWeekStart().millisecondsSinceEpoch;

    if (storedMs == null || storedMs < currentMs) {
      // New week — reset usage and bonus
      await prefs.setInt(_keyWeeklyUsage, 0);
      await prefs.setInt(_keyBonusUses, 0);
      await prefs.setInt(_keyWeekStart, currentMs);
    }
  }

  // ── Firestore sync (optional, when authenticated) ─────────────────────

  Future<void> _syncToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      await FirebaseFirestore.instance
          .collection('ai_usage')
          .doc(user.uid)
          .set({
        'weeklyUsage': prefs.getInt(_keyWeeklyUsage) ?? 0,
        'bonusUses': prefs.getInt(_keyBonusUses) ?? 0,
        'weekStart': prefs.getInt(_keyWeekStart),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Firestore sync is best-effort; offline is fine
    }
  }
}
