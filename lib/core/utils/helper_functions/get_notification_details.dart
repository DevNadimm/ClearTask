import 'dart:math';

class GetNotificationDetails {
  static String getNotificationMessage(String taskName) {
    final messages = [
      '⏰ Don’t forget: $taskName',
      '📌 It’s time for: $taskName',
      '🧠 You planned to: $taskName',
      '✅ Ready to finish: $taskName?',
    ];

    return messages[Random().nextInt(messages.length)];
  }
}
