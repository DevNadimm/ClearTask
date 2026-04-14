import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/core/services/contact_service.dart';
import 'package:clear_task/core/utils/widgets/custom_divider.dart';
import 'package:clear_task/presentation/blocs/theme/theme_cubit.dart';
import 'package:clear_task/presentation/blocs/wallet/wallet_cubit.dart';
import 'package:clear_task/presentation/screens/analytics/analytics_screen.dart';
import 'package:clear_task/presentation/screens/cloud_backup_screen.dart';
import 'package:clear_task/presentation/screens/developer_info_screen.dart';
import 'package:clear_task/presentation/screens/plan_my_day_screen.dart';
import 'package:clear_task/presentation/screens/pomodoro/pomodoro_screen.dart';
import 'package:clear_task/presentation/screens/rewards/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeDrawerColumn extends StatelessWidget {
  const HomeDrawerColumn({super.key});

  @override
  Widget build(BuildContext context) {
    IconData themeIcon(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return HugeIcons.strokeRoundedSun03;
        case ThemeMode.dark:
          return HugeIcons.strokeRoundedMoon02;
        case ThemeMode.system:
          return HugeIcons.strokeRoundedSmartPhone01;
      }
    }

    String themeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return 'Light Theme';
        case ThemeMode.dark:
          return 'Dark Theme';
        case ThemeMode.system:
          return 'System Theme';
      }
    }

    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: context.cardColor),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/clear_task_icon_png.png', scale: 15),
                const SizedBox(height: 10),
                Text(
                  'Clear Task',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.primaryFontColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedAiBrain01),
          title: const _TitleWidget('Plan My Day'),
          trailing: const _TrailingWidget('AI'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => const PlanMyDayScreen());
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedCoins01),
          title: const _TitleWidget('Rewards'),
          trailing: BlocBuilder<WalletCubit, WalletState>(
            builder: (context, walletState) {
              final coins = walletState.wallet?.coins ?? 0;
              return _TrailingWidget('$coins');
            },
          ),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => const RewardsScreen());
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedAnalytics01),
          title: const _TitleWidget('Analytics'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => const AnalyticsScreen());
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedTimer01),
          title: const _TitleWidget('Focus Timer'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => const PomodoroScreen());
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedCloud),
          title: const _TitleWidget('Cloud Backup'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => const CloudBackupScreen());
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedUser03),
          title: const _TitleWidget('Developer Info'),
          onTap: () {
            Navigator.pop(context);
            Get.to(() => const DeveloperInfoScreen());
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedAlertCircle),
          title: const _TitleWidget('Report Bug'),
          onTap: () {
            Navigator.pop(context);
            ContactService.reportBug();
          },
        ),
        ListTile(
          leading: const _LeadingWidget(HugeIcons.strokeRoundedAiMagic),
          title: const _TitleWidget('Request Feature'),
          onTap: () {
            Navigator.pop(context);
            ContactService.requestFeature();
          },
        ),
        const CustomDivider(),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return ListTile(
              leading: Icon(themeIcon(mode), color: AppColors.primaryColor),
              title: _TitleWidget(themeLabel(mode)),
              subtitle: Text(
                'Tap to switch',
                style: GoogleFonts.poppins(fontSize: 11, color: context.secondaryFontColor),
              ),
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
            );
          },
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          child: Text(
            'Version 1.1.0',
            style: GoogleFonts.poppins(color: context.secondaryFontColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _TitleWidget extends StatelessWidget {
  final String title;

  const _TitleWidget(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(color: context.primaryFontColor),
    );
  }
}

class _LeadingWidget extends StatelessWidget {
  final IconData icon;

  const _LeadingWidget(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: AppColors.primaryColor,
    );
  }
}

class _TrailingWidget extends StatelessWidget {
  final String label;

  const _TrailingWidget(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
