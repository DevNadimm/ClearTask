import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignupBonusDialog extends StatefulWidget {
  const SignupBonusDialog({super.key});

  @override
  State<SignupBonusDialog> createState() => _SignupBonusDialogState();
}

class _SignupBonusDialogState extends State<SignupBonusDialog> {
  @override
  void initState() {
    super.initState();
    SoundService().playCelebration();
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
                const SizedBox(height: 100),
                Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: context.primaryFontColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Thank you for joining ClearTask! Here's a special starter gift to help you plan your day.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: context.secondaryFontColor,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRewardItem(
                      context,
                      icon: Icons.flash_on,
                      label: '+20 XP',
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 10),
                    _buildRewardItem(
                      context,
                      icon: Icons.stars_rounded,
                      label: '+30 Coins',
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
                      "Start Productivity",
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
                repeat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context,
      {required IconData icon, required String label, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.primaryFontColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}