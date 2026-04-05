import 'package:clear_task/data/datasources/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DBHelper _dbHelper = DBHelper();

  /// Push all unsynced local tasks (with subtasks) to Firestore.
  Future<void> pushToCloud(String userId) async {
    final unsynced = await _dbHelper.fetchUnsyncedTasks();
    if (unsynced.isEmpty) {
      debugPrint('🔄 Sync: No unsynced tasks to push');
      return;
    }
    debugPrint('🔄 Sync: ${unsynced.length} unsynced tasks to push');

    final collection =
        _firestore.collection('users').doc(userId).collection('tasks');
    final db = await _dbHelper.initDB();

    for (final map in unsynced) {
      final localId = map['id'] as int;
      final cloudId = map['cloudId'] as String?;
      final isDeleted = (map['isDeleted'] as int?) == 1;

      try {
        if (isDeleted) {
          if (cloudId != null) {
            debugPrint('  ☁️ Deleting cloud task: $cloudId (localId: $localId)');
            await collection.doc(cloudId).delete();
            await _dbHelper.markSynced(localId, cloudId);
            debugPrint('  ☁️ Deleted cloud task successfully: $cloudId');
          } else {
            // Task was deleted locally before it was ever synced
            debugPrint('  ☁️ Purging local-only deleted task: localId: $localId');
            await _dbHelper.markSynced(localId, "purged"); 
          }
        } else if (cloudId != null) {
          debugPrint('  ☁️ Updating cloud task: $cloudId (localId: $localId)');
          final subtaskMaps = await db.query(
            'tbl_subtask',
            where: 'taskId = ?',
            whereArgs: [localId],
          );
          await collection
              .doc(cloudId)
              .set(_toFirestoreMap(map, subtaskMaps));
          await _dbHelper.markSynced(localId, cloudId);
          debugPrint('  ☁️ Updated cloud task successfully: $cloudId');
        } else {
          debugPrint('  ☁️ Creating NEW cloud task for localId: $localId');
          final subtaskMaps = await db.query(
            'tbl_subtask',
            where: 'taskId = ?',
            whereArgs: [localId],
          );
          final docRef =
              await collection.add(_toFirestoreMap(map, subtaskMaps));
          await _dbHelper.markSynced(localId, docRef.id);
          debugPrint('  ☁️ Created cloud task successfully: ${docRef.id} for localId: $localId');
        }
      } catch (e) {
        debugPrint('  ❌ Error syncing task $localId: $e');
      }
    }

    await _dbHelper.purgeDeletedSyncedTasks();
    debugPrint('🔄 Sync push complete');
  }

  /// Pull tasks (with subtasks) from Firestore that don't exist locally.
  Future<void> pullFromCloud(String userId) async {
    final collection =
        _firestore.collection('users').doc(userId).collection('tasks');
    final snapshot = await collection.get();
    debugPrint('🔄 Sync: ${snapshot.docs.length} cloud tasks found');

    final db = await _dbHelper.initDB();
    for (final doc in snapshot.docs) {
      final cloudId = doc.id;
      final existing = await db.query(
        'tbl_task',
        where: 'cloudId = ?',
        whereArgs: [cloudId],
      );
      if (existing.isEmpty) {
        final data = doc.data();
        final taskId = await db.insert('tbl_task', {
          'title': data['title'] ?? '',
          'note': data['note'],
          'taskType': data['taskType'] ?? 'General',
          'priority': data['priority'] ?? 'none',
          'sendNotification': data['sendNotification'] ?? 0,
          'dueDate': data['dueDate'],
          'notificationTime': data['notificationTime'],
          'isCompleted': data['isCompleted'] ?? 0,
          'completedAt': data['completedAt'],
          'cloudId': cloudId,
          'isSynced': 1,
          'isDeleted': 0,
          'calendarEventId': data['calendarEventId'],
          'isXpAwarded': (data['isXpAwarded'] == true || data['isXpAwarded'] == 1) ? 1 : 0,
        });

        // Pull subtasks
        final subtasks = data['subtasks'];
        if (subtasks != null && subtasks is List) {
          for (final st in subtasks) {
            await db.insert('tbl_subtask', {
              'taskId': taskId,
              'title': st['title'] ?? '',
              'isCompleted': st['isCompleted'] ?? 0,
              'isXpAwarded': (st['isXpAwarded'] == true || st['isXpAwarded'] == 1) ? 1 : 0,
            });
          }
        }
        debugPrint('  📥 Pulled cloud task + subtasks: $cloudId');
      }
    }
    debugPrint('🔄 Sync pull complete');
  }

  /// Full sync: push first, then pull.
  Future<void> fullSync(String userId) async {
    await pushToCloud(userId);
    await pullFromCloud(userId);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> _toFirestoreMap(
    Map<String, dynamic> localMap,
    List<Map<String, dynamic>> subtaskMaps,
  ) {
    return {
      'title': localMap['title'],
      'note': localMap['note'],
      'taskType': localMap['taskType'],
      'priority': localMap['priority'],
      'sendNotification': localMap['sendNotification'],
      'dueDate': localMap['dueDate'],
      'notificationTime': localMap['notificationTime'],
      'isCompleted': localMap['isCompleted'],
      'completedAt': localMap['completedAt'],
      'calendarEventId': localMap['calendarEventId'],
      'isXpAwarded': localMap['isXpAwarded'],
      'subtasks': subtaskMaps
          .map((s) => {
                'title': s['title'],
                'isCompleted': s['isCompleted'],
                'isXpAwarded': s['isXpAwarded'],
              })
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
