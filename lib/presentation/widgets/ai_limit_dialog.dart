import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/services/rewarded_ad_service.dart';
import 'package:clear_task/presentation/blocs/premium/premium_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AiLimitDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: ctx.cardColor,
        title: Row(
          children: [
            const Icon(HugeIcons.strokeRoundedAlert02, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            Text(
              'AI Limit Reached',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: ctx.primaryFontColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve used all your free AI uses this week.\nWatch a short ad to get 2 more uses!',
              style: GoogleFonts.poppins(
                color: ctx.secondaryFontColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            // Watch Ad Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showRewardedAd(context);
                },
                icon: const Icon(HugeIcons.strokeRoundedVideo01, size: 20),
                label: Text(
                  'Watch Ad for +2 Uses',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: ctx.buttonFontColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showRewardedAd(BuildContext context) {
    RewardedAdService.show(
      onReward: (bonus) {
        context.read<PremiumCubit>().grantBonusUses(bonus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 You earned $bonus extra AI uses!',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.success,
          ),
        );
      },
      onAdNotReady: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ad is not ready yet. Please try again shortly.',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }
}
