import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String appName = "Clear Task";
    const String appDescription = "Clear Task helps you organize your day with simplicity. Quickly add tasks, mark them complete, and stay focused on what matters. Celebrate your progress or archive old tasks to keep your list fresh—designed to help you achieve more with less effort.";

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Image.asset(
                "assets/illustration/todo_illustration.png",
                scale: 6,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    appName,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    appDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offAll(() => const HomeScreen()),
                      label: const Text("Get Started"),
                      icon: const Icon(
                        HugeIcons.strokeRoundedArrowRight02,
                        size: 20,
                      ),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
