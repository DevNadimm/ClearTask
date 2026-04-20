import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/datasources/preferences_helper.dart';
import 'package:clear_task/presentation/blocs/auth/auth_cubit.dart';
import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state.status == AuthStatus.authenticated) {
            // Fail-safe: Ensure the first-time user flag is cleared upon login
            await PreferencesHelper().setUserVisited();
            Get.offAll(() => const HomeScreen());
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildPage(
                      visual: _buildIconVisual(
                        icon: HugeIcons.strokeRoundedTaskDaily02,
                      ),
                      title: "Clear Task",
                      description: "Plan better. Focus more.\nClear Task keeps your daily tasks simple, organized, and stress-free.",
                    ),
                    _buildPage(
                      visual: _buildIconVisual(
                        icon: HugeIcons.strokeRoundedCloud,
                      ),
                      title: "Keep Tasks Safe",
                      description: "Sign in with Google to enable cloud backup. Your tasks will be synced and safe even if you lose your phone.",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primaryColor,
                    dotColor: AppColors.primaryColor.withValues(alpha: 0.2),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
                child: _currentPage == 0
                    ? _buildNextButton()
                    : _buildFinalActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shared page layout — both pages use the exact same structure.
  Widget _buildPage({
    required Widget visual,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(child: visual),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.primaryFontColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: context.secondaryFontColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visual variant for icon-based content (page 2).
  Widget _buildIconVisual({required IconData icon}) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor.withValues(alpha: 0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Icon(
          icon,
          size: 100,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: const Text("Next"),
      ),
    );
  }

  Widget _buildFinalActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.cardColor,
              foregroundColor: context.primaryFontColor,
              side: BorderSide(color: context.inputBorderColor.withValues(alpha: 0.3)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/google.png', width: 24, height: 24),
                const SizedBox(width: 12),
                Text(
                  "Secure with Google",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Get.offAll(() => const HomeScreen()),
          child: Text(
            "Skip for Now",
            style: GoogleFonts.poppins(
              color: context.secondaryFontColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
