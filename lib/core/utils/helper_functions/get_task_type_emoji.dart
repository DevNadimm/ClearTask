String getTaskTypeEmoji(String taskType) {
  switch (taskType.toLowerCase()) {
    case 'development': // Programming / building stuff
      return '💻';
    case 'work': // Professional / office tasks
      return '💼';
    case 'learning': // Study / courses
      return '🧠';
    case 'projects': // Side projects / experiments
      return '🚀';
    case 'research': // Exploration / deep work
      return '💡';
    case 'career': // Job / interviews / growth
      return '🎯';
    case 'personal': // Self-growth / personal tasks
      return '🌟';
    case 'health': // Wellness / doctor visits
      return '❤️';
    case 'fitness': // Exercise / training
      return '💪';
    case 'finance': // Money / budgeting
      return '💎';
    case 'home': // House / domestic
      return '🏠';
    case 'shopping': // Purchases / fashion
      return '🛍️';
    case 'travel': // Trips / adventure
      return '✈️';
    case 'events': // Parties / celebrations
      return '📅';
    default: // Generic / other tasks
      return '📝';
  }
}
