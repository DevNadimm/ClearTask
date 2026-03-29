import 'package:clear_task/app.dart';
import 'package:clear_task/core/services/notification_service.dart';
import 'package:clear_task/data/services/rewarded_ad_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  RewardedAdService.preload();
  await NotificationService().init();
  runApp(const MyApp());
}
