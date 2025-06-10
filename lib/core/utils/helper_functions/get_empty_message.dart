String getEmptyMessage(String currentTab) {
  switch (currentTab) {
    case 'Today':
      return "No tasks assigned for today.\nEnjoy your free time!";
    case 'Tomorrow':
      return "No tasks assigned for tomorrow yet.\nPlan ahead and add some!";
    case 'Upcoming':
      return "No upcoming tasks assigned.\nYou're all set!";
    case 'Anytime':
      return "No tasks assigned for anytime.\nFeel free to add some!";
    case 'Completed':
      return "No tasks have been completed yet.\nKeep going!";
    case 'All':
    default:
      return "No tasks assigned.\nAdd a new task to get started!";
  }
}
