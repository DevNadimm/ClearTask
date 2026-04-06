import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/services/auth_service.dart';
import 'package:clear_task/data/models/user_profile_model.dart';
import 'package:clear_task/data/repositories/user_stats_repository.dart';
import 'package:clear_task/data/services/rewarded_ad_service.dart';
import 'package:clear_task/presentation/blocs/wallet/wallet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final AuthService _authService = AuthService();
  final UserStatsRepository _statsRepo = UserStatsRepository();
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    RewardedAdService.preload();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleWatchAd() {
    final user = _authService.currentUser;
    if (user == null) return;

    if (!RewardedAdService.isReady) {
      _showSnackbar('Ad is still loading. Please try again in a few seconds.',
          isError: true);
      RewardedAdService.preload();
      return;
    }

    setState(() => _isAdLoading = true);

    RewardedAdService.show(
      userId: user.uid,
      walletCubit: context.read<WalletCubit>(),
      onRewardSuccess: () {
        if (mounted) {
          setState(() => _isAdLoading = false);
          _showSnackbar('🎉 You earned 15 Coins!');
        }
      },
      onAdDismissed: () {
        if (mounted) setState(() => _isAdLoading = false);
      },
      onAdNotReady: () {
        if (mounted) {
          setState(() => _isAdLoading = false);
          _showSnackbar('Ad not ready yet.', isError: true);
        }
      },
    );
  }

  void _handleDailyClaim() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final cubit = context.read<WalletCubit>();
    final success = await cubit.claimDailyReward(user.uid);

    if (success) {
      _showSnackbar('🎁 Claimed 15 Daily Coins!');
    } else {
      _showSnackbar('You have already claimed your daily reward today!',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            size: 30,
            color: context.primaryFontColor,
          ),
        ),
        title: const Text('Rewards & Growth'),
      ),
      body: StreamBuilder<UserProfileModel?>(
        stream: _statsRepo.getUserProfileStream(),
        builder: (context, profileSnapshot) {
          final profile = profileSnapshot.data;

          return BlocBuilder<WalletCubit, WalletState>(
            builder: (context, walletState) {
              final coins = walletState.wallet?.coins ?? 0;
              final earned = walletState.wallet?.totalEarned ?? 0;
              final spent = walletState.wallet?.totalSpent ?? 0;

              return RefreshIndicator(
                onRefresh: () async {
                  if (_authService.currentUser != null) {
                    await context
                        .read<WalletCubit>()
                        .fetchWallet(_authService.currentUser!.uid);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Level Progress Card ──
                      if (profile != null) ...[
                        _buildLevelProgressCard(context, profile),
                        const SizedBox(height: 24),
                      ],

                      // ── Combined Wallet + Earn Card ──
                      _buildWalletAndEarnCard(context, coins),

                      const SizedBox(height: 32),

                      // ── Wallet Statistics ──
                      Text(
                        'Wallet Statistics',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.primaryFontColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              'Total Earned',
                              '$earned',
                              HugeIcons.strokeRoundedCircleArrowDown01,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              'Total Spent',
                              '$spent',
                              HugeIcons.strokeRoundedCircleArrowUp01,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Level Progress Card ──
  Widget _buildLevelProgressCard(BuildContext context, UserProfileModel profile) {
    int currentXpInLevel = profile.xp % 100;
    double progress = currentXpInLevel / 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.85)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${profile.level}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profile.rankTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(HugeIcons.strokeRoundedCrown,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP Progress',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                '$currentXpInLevel / 100 XP',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Combined Wallet + Earn Card ──
  Widget _buildWalletAndEarnCard(BuildContext context, int coins) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.inputBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Balance section ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Coin Balance',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.secondaryFontColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        HugeIcons.strokeRoundedCoins01,
                        size: 18,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$coins',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: context.primaryFontColor,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'coins',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.secondaryFontColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(HugeIcons.strokeRoundedAiMagic,
                        size: 13, color: AppColors.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Spend on AI Features',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Plan My Day · AI Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: context.secondaryFontColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: context.inputBorderColor, height: 1, thickness: 1),

          // ── Earn more section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Earn More Coins',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.secondaryFontColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                _ActionCard(
                  title: 'Daily Reward',
                  subtitle: 'Claim your 15 coins for being active today.',
                  icon: HugeIcons.strokeRoundedCalendar03,
                  buttonText: 'Claim Reward',
                  onTap: _handleDailyClaim,
                  iconColor: Colors.blueAccent,
                ),
                const SizedBox(height: 8),
                _ActionCard(
                  title: 'Watch & Earn',
                  subtitle: 'Watch a short video to support & get 15 coins.',
                  icon: HugeIcons.strokeRoundedVideo01,
                  buttonText: 'Watch Video',
                  onTap: _isAdLoading ? null : _handleWatchAd,
                  iconColor: Colors.redAccent,
                  isLoading: _isAdLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Card ──
  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: context.inputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.primaryFontColor,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.secondaryFontColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Card ──
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String buttonText;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.buttonText,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? context.inputBorderColor
                : context.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.primaryFontColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: context.secondaryFontColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 2.5,
                ),
              )
            else
              Icon(
                HugeIcons.strokeRoundedCircleArrowRight01,
                color: isEnabled
                    ? AppColors.primaryColor
                    : context.secondaryFontColor.withValues(alpha: 0.3),
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}