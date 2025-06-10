import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  Future<Database> initDB() async {
    String getDatabasePath = await getDatabasesPath();
    String path = join(getDatabasePath, "task.db");

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    String sql = '''
    CREATE TABLE tbl_task (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      taskType TEXT NOT NULL,
      sendNotification INTEGER NOT NULL,
      dueDate TEXT,
      notificationTime TEXT,
      isCompleted INTEGER NOT NULL
    )
    ''';

    await db.execute(sql);
    debugPrint('✅ Database created with table tbl_task');
  }

  Future<Task> createTask(Task task) async {
    final Database db = await initDB();
    int id = await db.insert("tbl_task", Task.toMap(task));
    task.id = id;
    debugPrint('➕ Inserted task with id: $id');
    return task;
  }

  Future<List<Task>> fetchTasks() async {
    final Database db = await initDB();
    var tasks = await db.query("tbl_task");
    debugPrint('📖 Read ${tasks.length} tasks from database');
    List<Task> taskList = tasks.isNotEmpty
        ? tasks.map((task) => Task.fromMap(task)).toList()
        : [];
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
    int count = await db.delete(
      "tbl_task",
      where: "id = ?",
      whereArgs: [id],
    );
    debugPrint('🗑️ Deleted task with id: $id, affected rows: $count');
    return count;
  }

  Future<int> deleteAllTasks() async {
    final Database db = await initDB();
    final int count = await db.delete("tbl_task");
    debugPrint('🗑️ Deleted all tasks, affected rows: $count');
    return count;
  }
}
