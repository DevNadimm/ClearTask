import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/utils/helper_functions/ad_helper.dart';
import 'package:clear_task/core/services/sound_service.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class TaskCompletionDialog extends StatefulWidget {
  const TaskCompletionDialog({super.key});

  @override
  State<TaskCompletionDialog> createState() => _TaskCompletionDialogState();
}

class _TaskCompletionDialogState extends State<TaskCompletionDialog> {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    SoundService().playCelebration();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          });

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _deleteTasks();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _deleteTasks();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (mounted) {
            setState(() {
              _isInterstitialAdReady = false;
            });
          }
        },
      ),
    );
  }

  void _deleteTasks() {
    if (!mounted) return;
    // Use BlocProvider to get the bloc before popping or after
    context.read<TaskBloc>().add(DeleteAllTasks());
    Get.back();
  }

  void _onDeleteAllTapped() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      _deleteTasks();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 100), // Space for floating Lottie
                Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: context.primaryFontColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You've completed all your tasks successfully.\nKeep up the great work!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: context.secondaryFontColor,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _onDeleteAllTapped,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Clear Finished Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: context.secondaryFontColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Stay and Relax',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -120,
            child: SizedBox(
              height: 250,
              width: 250,
              child: Lottie.asset(
                'assets/animations/celebration.json',
                repeat: false,
                animate: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
