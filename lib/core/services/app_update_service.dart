import 'package:in_app_update/in_app_update.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum UpdateMode { flexible, immediate }

class AppUpdateService {
  static Future<void> checkForUpdate(
    BuildContext context, {
    UpdateMode mode = UpdateMode.flexible,
  }) async {
    // ✅ Offline হলে সাথে সাথে return, Play Store call-ই করবে না
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint("ℹ️ Offline — skipping update check.");
      return;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        debugPrint("ℹ️ No update available.");
        return;
      }

      debugPrint("🔄 Update available. Mode: $mode");

      if (mode == UpdateMode.immediate) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
        debugPrint("✅ Flexible update applied.");
      }
    } catch (e) {
      debugPrint("❌ Update error: $e");
    }
  }
}
