import 'package:clear_task/app.dart';
import 'package:clear_task/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await NotificationService().init();
  runApp(const MyApp());
}
