import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  Future<Database> initDB() async {
    if (_db != null) return _db!;

    String getDatabasePath = await getDatabasesPath();
    String path = join(getDatabasePath, "task.db");

    _db = await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tbl_task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        note TEXT,
        taskType TEXT NOT NULL,
        priority TEXT DEFAULT 'none',
        sendNotification INTEGER NOT NULL,
        dueDate TEXT,
        notificationTime TEXT,
        isCompleted INTEGER NOT NULL,
        completedAt TEXT,
        cloudId TEXT,
        isSynced INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0,
        calendarEventId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tbl_subtask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        completedAt TEXT,
        FOREIGN KEY (taskId) REFERENCES tbl_task(id) ON DELETE CASCADE
      )
    ''');

    debugPrint('✅ Database created with tables tbl_task and tbl_subtask');
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tbl_subtask (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId INTEGER NOT NULL,
          title TEXT NOT NULL,
          isCompleted INTEGER NOT NULL,
          FOREIGN KEY (taskId) REFERENCES tbl_task(id) ON DELETE CASCADE
        )
      ''');
      debugPrint('🔄 Database upgraded to v2: tbl_subtask added');
    }
    
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tbl_task ADD COLUMN completedAt TEXT');
      debugPrint('🔄 Database upgraded to v3: completedAt column added to tbl_task');
    }

    if (oldVersion < 4) {
      await db.execute("ALTER TABLE tbl_task ADD COLUMN priority TEXT DEFAULT 'none'");
      debugPrint('🔄 Database upgraded to v4: priority column added to tbl_task');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE tbl_task ADD COLUMN cloudId TEXT');
      await db.execute('ALTER TABLE tbl_task ADD COLUMN isSynced INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE tbl_task ADD COLUMN isDeleted INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE tbl_task ADD COLUMN calendarEventId TEXT');
      debugPrint('🔄 Database upgraded to v5: sync columns added');
    }

    if (oldVersion < 6) {
      await db.execute('ALTER TABLE tbl_task ADD COLUMN note TEXT');
      debugPrint('🔄 Database upgraded to v6: note column added to tbl_task');
    }

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE tbl_subtask ADD COLUMN completedAt TEXT');
      debugPrint('🔄 Database upgraded to v7: completedAt column added to tbl_subtask');
    }
  }

  // ── Task CRUD ───────────────────────────────────────────────────────────────

  Future<Task> createTask(Task task) async {
    final Database db = await initDB();
    int id = await db.insert("tbl_task", Task.toMap(task));
    task.id = id;
    debugPrint('➕ Inserted task with id: $id');
    return task;
  }

  Future<List<Task>> fetchTasks() async {
    final Database db = await initDB();
    final taskMaps = await db.query(
      "tbl_task",
      where: "isDeleted = ?",
      whereArgs: [0],
    );
    debugPrint('📖 Read ${taskMaps.length} tasks from database');

    final List<Task> taskList = [];
    for (final map in taskMaps) {
      final task = Task.fromMap(map);
      task.subtasks = await _fetchSubtasksForTask(db, task.id!);
      taskList.add(task);
    }
    return taskList;
  }

  Future<Task> updateTask(Task task) async {
    final Database db = await initDB();
    final map = Task.toMap(task);
    map['isSynced'] = 0; // Force sync on update
    int count = await db.update(
      "tbl_task",
      map,
      where: "id = ?",
      whereArgs: [task.id],
    );
    debugPrint('🛠️ Updated task with id: ${task.id}, affected rows: $count');
    return task;
  }

  /// Soft-delete: marks as deleted so sync can push the deletion to cloud.
  /// If cloudId is null (never synced), hard-deletes immediately.
  Future<int> deleteTask(int id) async {
    final Database db = await initDB();
    final rows = await db.query("tbl_task", where: "id = ?", whereArgs: [id]);
    if (rows.isNotEmpty && rows.first['cloudId'] != null) {
      // Soft delete – let sync service push the deletion
      await db.update("tbl_task", {'isDeleted': 1, 'isSynced': 0}, where: "id = ?", whereArgs: [id]);
      debugPrint('🗑️ Soft-deleted task id: $id');
      return 1;
    }
    // Hard delete – never synced
    await db.delete("tbl_subtask", where: "taskId = ?", whereArgs: [id]);
    int count = await db.delete("tbl_task", where: "id = ?", whereArgs: [id]);
    debugPrint('🗑️ Hard-deleted task id: $id, rows: $count');
    return count;
  }

  Future<int> deleteAllTasks() async {
    final Database db = await initDB();
    
    // Mark ALL tasks as deleted and unsynced so the sync service can decide what to do.
    // Synced tasks (cloudId != null) will be deleted from cloud.
    // Unsynced tasks (cloudId == null) will just be purged locally.
    int count = await db.update(
      "tbl_task", 
      {'isDeleted': 1, 'isSynced': 0}
    );

    // Subtasks can be hard-deleted locally as they are synced as part of the task object.
    await db.delete("tbl_subtask");

    debugPrint('🗑️ Marked all tasks for deletion: $count rows');
    return count;
  }

  // ── Subtask CRUD ─────────────────────────────────────────────────────────────

  Future<Subtask> createSubtask(Subtask subtask) async {
    final Database db = await initDB();
    int id = await db.insert("tbl_subtask", Subtask.toMap(subtask));
    
    // Reset parent task sync status
    await db.update("tbl_task", {'isSynced': 0}, 
        where: "id = ?", whereArgs: [subtask.taskId]);

    debugPrint('➕ Inserted subtask with id: $id');
    return subtask.copyWith(id: id);
  }

  Future<Subtask> updateSubtask(Subtask subtask) async {
    final Database db = await initDB();
    await db.update(
      "tbl_subtask",
      Subtask.toMap(subtask),
      where: "id = ?",
      whereArgs: [subtask.id],
    );

    // Reset parent task sync status
    await db.update("tbl_task", {'isSynced': 0}, 
        where: "id = ?", whereArgs: [subtask.taskId]);

    debugPrint('🛠️ Updated subtask with id: ${subtask.id}');
    return subtask;
  }

  Future<int> deleteSubtask(int id) async {
    final Database db = await initDB();
    
    // Fetch taskId before deleting to reset its sync status
    final maps = await db.query("tbl_subtask", columns: ["taskId"], where: "id = ?", whereArgs: [id]);
    if (maps.isNotEmpty) {
      int taskId = maps.first["taskId"] as int;
      await db.update("tbl_task", {'isSynced': 0}, where: "id = ?", whereArgs: [taskId]);
    }

    int count = await db.delete("tbl_subtask", where: "id = ?", whereArgs: [id]);
    debugPrint('🗑️ Deleted subtask with id: $id');
    return count;
  }

  // ── Sync helpers ────────────────────────────────────────────────────────────

  /// Returns all tasks that haven't been synced yet (isSynced = 0), including
  /// soft-deleted tasks that still need their deletion pushed to the cloud.
  Future<List<Map<String, dynamic>>> fetchUnsyncedTasks() async {
    final Database db = await initDB();
    return db.query("tbl_task", where: "isSynced = ?", whereArgs: [0]);
  }

  /// Mark a task as synced and set its cloudId.
  Future<void> markSynced(int localId, String cloudId) async {
    final Database db = await initDB();
    await db.update(
      "tbl_task",
      {'isSynced': 1, 'cloudId': cloudId},
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  /// Hard-delete tasks that are marked as deleted AND synced.
  Future<void> purgeDeletedSyncedTasks() async {
    final Database db = await initDB();
    
    // Case 1: Synced tasks that were deleted (isSynced=1 means pushToCloud just finished deleting them)
    // Case 2: Unsynced tasks that were deleted (cloudId IS NULL means they never reached the cloud)
    int count = await db.delete("tbl_task",
        where: "isDeleted = ? AND (isSynced = ? OR cloudId IS NULL)", 
        whereArgs: [1, 1]);
        
    if (count > 0) {
      debugPrint('🧹 Purged $count deleted tasks from local database');
    }
  }

  /// Save calendarEventId for a task.
  Future<void> setCalendarEventId(int localId, String? eventId) async {
    final Database db = await initDB();
    await db.update(
      "tbl_task",
      {'calendarEventId': eventId},
      where: "id = ?",
      whereArgs: [localId],
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  Future<List<Subtask>> _fetchSubtasksForTask(Database db, int taskId) async {
    final maps = await db.query(
      "tbl_subtask",
      where: "taskId = ?",
      whereArgs: [taskId],
    );
    return maps.map((m) => Subtask.fromMap(m)).toList();
  }
}