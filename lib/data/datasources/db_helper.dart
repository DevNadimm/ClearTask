import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  Future<Database> initDB() async {
    String getDatabasePath = await getDatabasesPath();
    String path = join(getDatabasePath, "task.db");

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tbl_task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        taskType TEXT NOT NULL,
        sendNotification INTEGER NOT NULL,
        dueDate TEXT,
        notificationTime TEXT,
        isCompleted INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tbl_subtask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
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
    final taskMaps = await db.query("tbl_task");
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
    int count = await db.update(
      "tbl_task",
      Task.toMap(task),
      where: "id = ?",
      whereArgs: [task.id],
    );
    debugPrint('🛠️ Updated task with id: ${task.id}, affected rows: $count');
    return task;
  }

  Future<int> deleteTask(int id) async {
    final Database db = await initDB();
    // Delete subtasks first (cascade safety for older SQLite builds)
    await db.delete("tbl_subtask", where: "taskId = ?", whereArgs: [id]);
    int count = await db.delete("tbl_task", where: "id = ?", whereArgs: [id]);
    debugPrint('🗑️ Deleted task with id: $id, affected rows: $count');
    return count;
  }

  Future<int> deleteAllTasks() async {
    final Database db = await initDB();
    await db.delete("tbl_subtask");
    final int count = await db.delete("tbl_task");
    debugPrint('🗑️ Deleted all tasks, affected rows: $count');
    return count;
  }

  // ── Subtask CRUD ─────────────────────────────────────────────────────────────

  Future<Subtask> createSubtask(Subtask subtask) async {
    final Database db = await initDB();
    int id = await db.insert("tbl_subtask", Subtask.toMap(subtask));
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
    debugPrint('🛠️ Updated subtask with id: ${subtask.id}');
    return subtask;
  }

  Future<int> deleteSubtask(int id) async {
    final Database db = await initDB();
    int count = await db.delete("tbl_subtask", where: "id = ?", whereArgs: [id]);
    debugPrint('🗑️ Deleted subtask with id: $id');
    return count;
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
