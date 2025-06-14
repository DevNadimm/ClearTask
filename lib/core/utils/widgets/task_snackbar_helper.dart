import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskSnackBarHelper {
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 16,
      duration: const Duration(seconds: 4),
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: true,
      overlayBlur: 0.5,
    );
  }

  /* ────────── SUCCESS ────────── */

  static void showCreateSuccess() => _show(
    title: "Task Created",
    message: "Your task has been successfully added. Keep up the productivity!",
    backgroundColor: Colors.green,
    icon: Icons.check_circle_outline,
  );

  static void showUpdateSuccess() => _show(
    title: "Task Updated",
    message: "Changes saved. Your task details have been updated.",
    backgroundColor: Colors.green,
    icon: Icons.check_circle_outline,
  );

  static void showDeleteSuccess() => _show(
    title: "Task Deleted",
    message: "Task removed from your list. Focus on what matters next.",
    backgroundColor: Colors.green,
    icon: Icons.check_circle_outline,
  );

  static void showDeleteAllSuccess() => _show(
    title: "All Tasks Cleared",
    message: "All tasks were deleted. You’re starting fresh!",
    backgroundColor: Colors.green,
    icon: Icons.check_circle_outline,
  );

  /* ────────── FAILURE ────────── */

  static void showCreateFailed() => _show(
    title: "Failed to Create",
    message: "Could not add the task. Please try again later.",
    backgroundColor: Colors.red,
    icon: Icons.error_outline,
  );

  static void showUpdateFailed() => _show(
    title: "Update Failed",
    message: "Something went wrong while saving your changes.",
    backgroundColor: Colors.red,
    icon: Icons.error_outline,
  );

  static void showDeleteFailed() => _show(
    title: "Deletion Failed",
    message: "Task could not be deleted. Please check and try again.",
    backgroundColor: Colors.red,
    icon: Icons.error_outline,
  );

  static void showDeleteAllFailed() => _show(
    title: "Bulk Deletion Failed",
    message: "Couldn’t delete all tasks. Try again in a moment.",
    backgroundColor: Colors.red,
    icon: Icons.error_outline,
  );
}
