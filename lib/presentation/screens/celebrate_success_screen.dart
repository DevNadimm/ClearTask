import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class CelebrateSuccessScreen extends StatelessWidget {
  const CelebrateSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 250,
                child: Lottie.asset('assets/animations/celebration.json'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryFontColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You’ve completed all your tasks successfully.\nKeep up the great work!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryFontColor,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<TaskBloc>().add(DeleteAllTasks());
                    Get.offAll(() => const HomeScreen());
                  },
                  icon: const Icon(
                    HugeIcons.strokeRoundedDelete02,
                    size: 20,
                  ),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Delete All Tasks'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Get.offAll(() => const HomeScreen());
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(color: AppColors.secondaryFontColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
