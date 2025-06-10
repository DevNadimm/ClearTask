class ErrorMessages {
  static const String fetchFailed =
      'Unable to load tasks at the moment.\nPlease check your internet connection or try again later.';

  static const String createFailed =
      'Task creation failed.\nPlease ensure all required fields are correctly filled and try again.';

  static const String updateFailed =
      'Unable to update the task.\nThe task may no longer exist or there might be a problem with the server.';

  static const String deleteFailed =
      'Failed to delete the task.\nPlease try again. If the issue persists, contact support.';

  static const String deleteAllFailed =
      'Failed to delete all tasks.\nPlease try again. If the issue persists, contact support.';

  static const String taskNotFound =
      'The requested task was not found.\nIt might have been removed or the ID is incorrect.';

  static const String invalidData =
      'Invalid data provided.\nPlease review your input and try again.';

  static const String unknownError =
      'An unexpected error occurred.\nPlease try again later or restart the app.';
}
