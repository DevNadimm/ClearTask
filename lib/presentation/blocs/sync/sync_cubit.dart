import 'dart:async';
import 'package:clear_task/core/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SyncStatus { idle, syncing, synced, error, offline }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSynced;

  const SyncState({
    required this.status,
    this.lastSynced,
  });

  SyncState copyWith({SyncStatus? status, DateTime? lastSynced}) {
    return SyncState(
      status: status ?? this.status,
      lastSynced: lastSynced ?? this.lastSynced,
    );
  }
}

class SyncCubit extends Cubit<SyncState> {
  final SyncService _syncService = SyncService();
  StreamSubscription? _connectivitySub;
  String? _userId;

  /// Called after every successful sync so the UI can reload tasks.
  VoidCallback? onSyncComplete;

  SyncCubit() : super(const SyncState(status: SyncStatus.idle)) {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (_userId != null && results.any((r) => r != ConnectivityResult.none)) {
        sync(_userId!);
      }
    });

    _autoSyncOnStartup();
  }

  Future<void> _autoSyncOnStartup() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.any((r) => r != ConnectivityResult.none)) {
        sync(user.uid);
      }
    }
  }

  void setUser(String userId) {
    _userId = userId;
  }

  void clearUser() {
    _userId = null;
    emit(const SyncState(status: SyncStatus.idle));
  }

  Future<void> sync(String userId) async {
    if (state.status == SyncStatus.syncing) return;
    _userId = userId;
    emit(state.copyWith(status: SyncStatus.syncing));
    try {
      await _syncService.fullSync(userId);
      emit(state.copyWith(status: SyncStatus.synced, lastSynced: DateTime.now()));
      onSyncComplete?.call();
      debugPrint('✅ Full sync complete');
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      emit(state.copyWith(status: SyncStatus.error));
    }
  }

  Future<void> pushIfLoggedIn() async {
    if (_userId == null) return;
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.any((r) => r != ConnectivityResult.none)) {
      try {
        await _syncService.pushToCloud(_userId!);
        emit(state.copyWith(status: SyncStatus.synced, lastSynced: DateTime.now()));
      } catch (e) {
        debugPrint('⚠️ Background push failed: $e');
      }
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
