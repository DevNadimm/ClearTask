import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/ad_helper.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:clear_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class CelebrateSuccessScreen extends StatefulWidget {
  const CelebrateSuccessScreen({super.key});

  @override
  State<CelebrateSuccessScreen> createState() => _CelebrateSuccessScreenState();
}

class _CelebrateSuccessScreenState extends State<CelebrateSuccessScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              context.read<TaskBloc>().add(DeleteAllTasks());
              Get.offAll(() => const HomeScreen());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              context.read<TaskBloc>().add(DeleteAllTasks());
              Get.offAll(() => const HomeScreen());
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _onDeleteAllTapped() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      context.read<TaskBloc>().add(DeleteAllTasks());
      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 250,
                child: Lottie.asset(
                  'assets/animations/celebration.json',
                  controller: _animationController,
                  onLoaded: (composition) {
                    _animationController.duration = composition.duration;
                    _animationController.forward();
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Congratulations!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryFontColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You've completed all your tasks successfully.\nKeep up the great work!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.secondaryFontColor,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _onDeleteAllTapped,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Delete All Tasks',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: AppColors.secondaryFontColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
