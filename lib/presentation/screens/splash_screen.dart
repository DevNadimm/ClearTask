import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/services/app_update_service.dart';
import 'package:clear_task/data/datasources/preferences_helper.dart';
import 'package:clear_task/presentation/blocs/auth/auth_cubit.dart';
import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:clear_task/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    // Consolidated navigation logic into a single post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check for updates first
      await AppUpdateService.checkForUpdate(context);
      // Then proceed to check auth and navigate
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    final PreferencesHelper prefHelper = PreferencesHelper();
    
    // 1. Start fetching preferences and branding delay in parallel
    final firstTimeFuture = prefHelper.isFirstTimeUser();
    final minDelayFuture = Future.delayed(const Duration(seconds: 2));

    // 2. Wait for AuthCubit to determine the initial session status
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state.status == AuthStatus.initial) {
      await authCubit.stream.firstWhere((state) => state.status != AuthStatus.initial);
    }

    // 3. Gather all results
    final bool isAuthenticated = authCubit.state.status == AuthStatus.authenticated;
    final bool isFirstTimeUser = await firstTimeFuture;
    
    // Ensure branding animation has shown for at least 2s
    await minDelayFuture;

    if (!mounted) return;

    // 4. Decision Logic
    if (isAuthenticated) {
      // Priority 1: User is already logged in -> Go Home
      // (Even if it's technically their "first time", if they are authenticated, they should go to Home)
      if (isFirstTimeUser) await prefHelper.setUserVisited();
      Get.offAll(() => const HomeScreen());
    } else if (isFirstTimeUser) {
      // Priority 2: Unauthenticated and New User -> Welcome/Login
      await prefHelper.setUserVisited();
      Get.offAll(() => const WelcomeScreen());
    } else {
      // Priority 3: Unauthenticated but Returning User -> Home (Skip mode)
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
