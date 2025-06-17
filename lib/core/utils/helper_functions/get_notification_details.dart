import 'dart:math';
import 'package:clear_task/data/models/task_model.dart';

class GetNotificationDetails {
  // Random generator to pick random templates
  static final Random _random = Random();

  // Predefined messages for each task type
  static final Map<String, List<Map<String, String>>> _messageTemplates = {
    "Office": [
      {"📌 Task Reminder": "Don't forget to finish \"{title}\"."},
      {"✅ Time to Work": "Let’s complete \"{title}\" and stay on track."},
      {"⏰ Focus Time": "\"{title}\" is scheduled. Give it your best!"},
    ],
    "Home": [
      {"🏠 Home Task": "Remember to complete \"{title}\" today."},
      {"📝 Task Alert": "\"{title}\" is waiting for you."},
      {"🔔 Reminder": "Stay productive! Time for \"{title}\"."},
    ],
    "Study": [
      {"📚 Study Task": "Let’s work on \"{title}\" and make progress."},
      {"🧠 Focus Mode": "\"{title}\" is your next step to success."},
      {"✏️ Time to Learn": "Stay sharp! Let’s do \"{title}\"."},
    ],
    "Fitness": [
      {"💪 Fitness Task": "Let’s stay active — complete \"{title}\"."},
      {"🏃 Get Moving": "Don’t forget about \"{title}\"."},
      {"🔥 Action Time": "Power up! It’s time for \"{title}\"."},
    ],
    "Shopping": [
      {"🛒 To Buy": "\"{title}\" is on your list."},
      {"📦 Shopping Task": "Add \"{title}\" to your cart!"},
      {"📋 Task Reminder": "Check off \"{title}\" today."},
    ],
    "Health": [
      {"❤️ Health First": "Don’t skip \"{title}\" — take care of yourself."},
      {"🩺 Reminder": "Time to complete your health task: \"{title}\"."},
      {"💊 Stay Well": "\"{title}\" is an important step for your health."},
    ],
    "Personal": [
      {"🌟 Personal Goal": "Time to accomplish \"{title}\"."},
      {"🕰️ Just for You": "\"{title}\" is your task today."},
      {"🎯 Stay on Track": "Focus and finish \"{title}\"."},
    ],
    "Finance": [
      {"💰 Money Matters": "Take care of \"{title}\" now."},
      {"📈 Financial Task": "Handle \"{title}\" wisely."},
      {"🧾 Don't Delay": "\"{title}\" is on your to-do list."},
    ],
    "Others": [
      {"📌 Task Reminder": "Don’t forget about \"{title}\"."},
      {"⏰ Scheduled Task": "Time to take care of \"{title}\"."},
      {"📝 Do It Now": "Let’s complete \"{title}\" today."},
    ],
  };

  // Get all templates for the given task type
  static List<Map<String, String>> _getTemplates(String type) {
    // If the type doesn't exist, use "Others"
    return _messageTemplates[type] ?? _messageTemplates["Others"]!;
  }

  // Get one random title-body pair for the given task
  static MapEntry<String, String> _getRandomNotification(Task task) {
    final templates = _getTemplates(task.taskType);
    final randomTemplate = templates[_random.nextInt(templates.length)];
    final entry = randomTemplate.entries.first;

    // Replace {title} with actual task title in the body
    final String finalBody = entry.value.replaceAll("{title}", task.title);

    return MapEntry(entry.key, finalBody);
  }

  // Get only the title
  static String getNotificationTitle(Task task) {
    return _getRandomNotification(task).key;
  }

  // Get only the body
  static String getNotificationBody(Task task) {
    return _getRandomNotification(task).value;
  }

  // Optional: Get both title and body at once
  static MapEntry<String, String> getNotificationPair(Task task) {
    return _getRandomNotification(task);
  }
}
