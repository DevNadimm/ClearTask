import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/data/services/rewarded_ad_service.dart';
import 'package:clear_task/presentation/blocs/auth/auth_cubit.dart';
import 'package:clear_task/presentation/blocs/credit/credit_cubit.dart';
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
              'AI Credits',
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
            Builder(
              builder: (ctx) {
                final authState = ctx.read<AuthCubit>().state;
                if (authState.status != AuthStatus.authenticated) {
                  return Text(
                    'You must be logged in to use AI features and earn credits.',
                    style: GoogleFonts.poppins(
                      color: ctx.secondaryFontColor,
                      fontSize: 14,
                    ),
                  );
                }

                return Text(
                  'You\'ve run out of AI credits.\nWatch a short ad to earn +1 credit!',
                  style: GoogleFonts.poppins(
                    color: ctx.secondaryFontColor,
                    fontSize: 14,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Watch Ad Button
            Builder(
              builder: (ctx) {
                final authState = ctx.read<AuthCubit>().state;
                final bool isLoggedIn = authState.status == AuthStatus.authenticated;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !isLoggedIn ? null : () {
                      Navigator.pop(ctx);
                      _showRewardedAd(context, authState.user!.uid);
                    },
                    child: Text(
                      isLoggedIn ? 'Watch Ad for +1 Credit' : 'Login Required',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showRewardedAd(BuildContext context, String userId) {
    final creditCubit = context.read<CreditCubit>();
    RewardedAdService.show(
      userId: userId,
      creditCubit: creditCubit,
      onRewardSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 You earned +1 AI credit!',
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
