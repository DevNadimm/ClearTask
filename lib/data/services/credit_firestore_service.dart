import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clear_task/data/models/user_credit_model.dart';
import 'package:flutter/foundation.dart';

class CreditFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Get credit data for a specific user
  Future<UserCreditModel?> getCredit(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).collection('credit').doc('data').get();
      if (doc.exists) {
        return UserCreditModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      
      // Auto-initialize for returning users who somehow lack a credit document
      debugPrint('ℹ️ Credit document missing for user $userId. Initializing with 0 credits.');
      final initialCredit = UserCreditModel.initial();
      await updateCredit(userId, initialCredit);
      return initialCredit;
    } catch (e) {
      debugPrint('❌ Error fetching credit: $e');
      rethrow;
    }
  }

  /// Initialize or update credit data
  Future<void> updateCredit(String userId, UserCreditModel credit) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('credit')
          .doc('data')
          .set(credit.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Error updating credit: $e');
      rethrow;
    }
  }

  /// Grant daily credit transactionally to ensure it only happens once per day.
  /// This uses server-side timestamp for verification.
  Future<bool> grantDailyCredit(String userId) async {
    final docRef = _usersCollection.doc(userId).collection('credit').doc('data');

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final lastGrantTimestamp = data['lastDailyGrant'] as Timestamp?;
          
          if (lastGrantTimestamp != null) {
            final lastGrantDate = lastGrantTimestamp.toDate();
            final lastGrantDay = DateTime(lastGrantDate.year, lastGrantDate.month, lastGrantDate.day);
            
            // If already granted today, skip
            if (lastGrantDay.isAtSameMomentAs(today) || lastGrantDay.isAfter(today)) {
              return false;
            }
          }

          // Update existing
          transaction.update(docRef, {
            'balance': FieldValue.increment(1),
            'lastDailyGrant': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new record (fallback, should normally be created at signup)
          transaction.set(docRef, {
            'balance': 1,
            'totalSpent': 0,
            'lastDailyGrant': FieldValue.serverTimestamp(),
          });
        }
        return true;
      });
    } catch (e) {
      debugPrint('❌ Error granting daily credit: $e');
      return false;
    }
  }

  /// Spend credit with a check to prevent negative balance
  Future<bool> spendCredit(String userId, int amount) async {
    final docRef = _usersCollection.doc(userId).collection('credit').doc('data');

    try {
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (!snapshot.exists) return false;

        final data = snapshot.data() as Map<String, dynamic>;
        final currentBalance = data['balance'] as int? ?? 0;

        if (currentBalance < amount) return false;

        transaction.update(docRef, {
          'balance': FieldValue.increment(-amount),
          'totalSpent': FieldValue.increment(amount),
        });
        
        return true;
      });
    } catch (e) {
      debugPrint('❌ Error spending credit: $e');
      return false;
    }
  }

  /// Add credit (e.g. from ads)
  Future<void> addCredit(String userId, int amount) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('credit')
          .doc('data')
          .update({
        'balance': FieldValue.increment(amount),
      });
    } catch (e) {
      // If document doesn't exist, Create it
      if (e is FirebaseException && e.code == 'not-found') {
        await _usersCollection.doc(userId).collection('credit').doc('data').set({
          'balance': amount,
          'totalSpent': 0,
          'lastDailyGrant': null,
        });
      } else {
        debugPrint('❌ Error adding credit: $e');
        rethrow;
      }
    }
  }
}
