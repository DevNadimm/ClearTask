import 'dart:math';

class GetNotificationDetails {
  static String getNotificationMessage(String taskName) {
    final messages = [
      'Quick task check 👀 — $taskName',
      'This is pending — $taskName',
      'One thing left today — $taskName',
      'Let’s clear this — $taskName',
      'Focus mode on — $taskName',
      'Progress waits for no one — $taskName',
      'Small progress beats none — $taskName',
      'You’re closer than you think — $taskName',
      'Just one task — $taskName',
      'Task in progress — $taskName',
      'Next up — $taskName',
      'Pending task — $taskName',
      'Time to focus on — $taskName',
    ];

    return messages[Random().nextInt(messages.length)];
  }
}
