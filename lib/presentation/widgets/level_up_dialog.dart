import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  const LevelUpDialog({super.key, required this.newLevel});

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    SoundService().playCelebration();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  'LEVEL UP!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You reached Level ${widget.newLevel}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.primaryFontColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Your productivity is skyrocketing! Keep up the amazing work and unlock more ranks.',
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
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Awesome!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
