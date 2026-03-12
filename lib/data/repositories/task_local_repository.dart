import 'package:clear_task/data/datasources/db_helper.dart';
import 'package:clear_task/data/models/task_model.dart';

class TaskLocalRepository {
  final DBHelper dbHelper = DBHelper();

  // ── Task ─────────────────────────────────────────────────────────────────────

  Future<List<Task>> fetchTasks() => dbHelper.fetchTasks();

  Future<Task> createTask(Task task) => dbHelper.createTask(task);

  Future<Task> updateTask(Task task) => dbHelper.updateTask(task);

  Future deleteTask(int id) => dbHelper.deleteTask(id);

  Future deleteAllTasks() => dbHelper.deleteAllTasks();

  // ── Subtask ──────────────────────────────────────────────────────────────────

  Future<Subtask> createSubtask(Subtask subtask) => dbHelper.createSubtask(subtask);

  Future<Subtask> updateSubtask(Subtask subtask) => dbHelper.updateSubtask(subtask);

  Future<int> deleteSubtask(int id) => dbHelper.deleteSubtask(id);
}
