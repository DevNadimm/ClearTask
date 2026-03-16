import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/datasources/preferences_helper.dart';
import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:clear_task/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final PreferencesHelper prefHelper = PreferencesHelper();
    final futurePrefs = prefHelper.isFirstTimeUser();

    await Future.delayed(const Duration(seconds: 2));
    final bool isFirstTimeUser = await futurePrefs;

    if (!mounted) return;

    if (isFirstTimeUser) {
      await prefHelper.setUserVisited();
      Get.offAll(() => const WelcomeScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/icons/clear_task_icon_png.png", height: 100),
                  const SizedBox(height: 10),
                  Text(
                    "Clear Task",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.primaryFontColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Simplify your day",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: context.secondaryFontColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
