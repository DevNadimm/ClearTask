import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Google Sign-In ──────────────────────────────────────────────────────────

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ Google sign-in success: ${userCredential.user?.email}');
      
      if (userCredential.user != null) {
        await _initializeUserData(userCredential.user!);
      }
      
      return userCredential.user;
    } catch (e) {
      debugPrint('❌ Google sign-in failed: $e');
      rethrow;
    }
  }



  // ── User Initialization ───────────────────────────────────────────────────

  Future<void> _initializeUserData(User user) async {
    final firestore = FirebaseFirestore.instance;
    final profileRef = firestore.collection('users').doc(user.uid).collection('profile').doc('data');
    final creditRef = firestore.collection('users').doc(user.uid).collection('credit').doc('data');

    try {
      final profileDoc = await profileRef.get();
      if (!profileDoc.exists) {
        debugPrint('🆕 New user detected. Initializing profile and credits...');
        
        final batch = firestore.batch();
        
        // 1. Create Profile
        batch.set(profileRef, {
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Create Credit with Signup Bonus (4)
        batch.set(creditRef, {
          'balance': 4,
          'totalSpent': 0,
          'lastDailyGrant': null,
        });

        await batch.commit();
        debugPrint('✅ User data initialized successfully.');
      } else {
        debugPrint('👋 Returning user detected. No re-initialization needed.');
      }
    } catch (e) {
      debugPrint('❌ Error initializing user data: $e');
      // We don't rethrow here to allow the user to still log in even if init fails
      // Missing data will be handled by CreditFirestoreService.getCredit
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    debugPrint('✅ Signed out');
  }

  // ── Google Sign-In instance (for Calendar API) ──────────────────────────────

  GoogleSignIn get googleSignIn => _googleSignIn;
}
