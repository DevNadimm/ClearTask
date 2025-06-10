import 'package:clear_task/core/services/db_helper.dart';
import 'package:clear_task/data/models/task_model.dart';

class Repository {
  final DBHelper dbHelper = DBHelper();

  Future<List<Task>> fetchTasks() => dbHelper.fetchTasks();

  Future<Task> createTask(Task task) => dbHelper.createTask(task);

  Future<Task> updateTask(Task task) => dbHelper.updateTask(task);

  Future deleteTask(int id) => dbHelper.deleteTask(id);

  Future deleteAllTasks() => dbHelper.deleteAllTasks();
}
