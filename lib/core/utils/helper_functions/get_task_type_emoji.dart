String getTaskTypeEmoji(String taskType) {
  final type = taskType.toLowerCase();

  if (type == 'office') {
    return '💼';
  } else if (type == 'home') {
    return '🏠';
  } else if (type == 'study') {
    return '📖';
  } else if (type == 'personal') {
    return '🧘';
  } else if (type == 'shopping') {
    return '🛒';
  } else if (type == 'fitness') {
    return '💪';
  } else if (type == 'health') {
    return '🩺';
  } else if (type == 'finance') {
    return '💳';
  } else if (type == 'travel') {
    return '✈️';
  } else if (type == 'event') {
    return '📅';
  } else {
    return '📝';
  }
}