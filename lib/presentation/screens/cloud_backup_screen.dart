import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/presentation/blocs/auth/auth_cubit.dart';
import 'package:clear_task/presentation/blocs/sync/sync_cubit.dart';
import 'package:clear_task/presentation/blocs/task/task_bloc.dart';
import 'package:clear_task/presentation/blocs/task/task_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class CloudBackupScreen extends StatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  State<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = DateFormat('yyyyMMdd').format(dateTime) ==
        DateFormat('yyyyMMdd').format(now);

    return isToday
        ? DateFormat('h:mm a').format(dateTime) // "2:05 PM"
        : DateFormat('MMM d, y h:mm a')
            .format(dateTime); // "Jan 15, 2025 2:05 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            HugeIcons.strokeRoundedArrowLeft01,
            size: 30,
            color: context.primaryFontColor,
          ),
        ),
        title: Text(
          'Cloud Backup',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: context.primaryFontColor,
          ),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState.status == AuthStatus.authenticated) {
            final userId = authState.user!.uid;
            context.read<SyncCubit>().setUser(userId);
            context.read<SyncCubit>().sync(userId);

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.read<TaskBloc>().add(FetchTasks());
              }
            });
          }
          if (authState.status == AuthStatus.error &&
              authState.errorMessage != null) {
            _showErrorSnackBar(authState.errorMessage!);
          }
        },
        builder: (context, authState) {
          if (authState.status == AuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: authState.status == AuthStatus.authenticated
                ? _buildLoggedInView(context, authState)
                : _buildLoginView(context),
          );
        },
      ),
    );
  }

  // ── Logged-in View ────────────────────────────────────────────────────────

  Widget _buildLoggedInView(BuildContext context, AuthState authState) {
    final user = authState.user!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Premium Profile Card
          _buildPremiumCard(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        child: user.photoURL != null
                            ? CachedNetworkImage(
                                imageUrl: user.photoURL!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: context.inputBorderColor
                                      .withValues(alpha: 0.2),
                                  highlightColor: context.cardColor,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : const Icon(Icons.person_rounded,
                                size: 40, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.primaryFontColor,
                  ),
                ),
                Text(
                  user.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: context.secondaryFontColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sync Section Header
          _buildSectionHeader(context, "Cloud Sync"),

          const SizedBox(height: 12),

          // Sync Status Card
          BlocBuilder<SyncCubit, SyncState>(
            builder: (context, syncState) {
              final status = syncState.status;
              final lastSynced = syncState.lastSynced;

              String lastSyncedText = lastSynced != null
                  ? 'Last synced: ${_formatDateTime(lastSynced)}'
                  : 'Never synced';

              return _buildPremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatusIndicator(status),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _syncLabel(status),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.primaryFontColor,
                                ),
                              ),
                              Text(
                                status == SyncStatus.syncing
                                    ? 'Updating your cloud storage...'
                                    : lastSyncedText,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: context.secondaryFontColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildActionButton(
                      context: context,
                      label: status == SyncStatus.syncing
                          ? 'Syncing...'
                          : 'Force Sync',
                      icon: HugeIcons.strokeRoundedRefresh,
                      isLoading: status == SyncStatus.syncing,
                      onPressed: () {
                        context.read<SyncCubit>().sync(user.uid);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            context.read<TaskBloc>().add(FetchTasks());
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Sign out
          TextButton(
            onPressed: () {
              context.read<SyncCubit>().clearUser();
              context.read<AuthCubit>().signOut();
            },
            child: Text(
              'Sign Out from Account',
              style: GoogleFonts.poppins(
                color: AppColors.error.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                fontSize: 15,
                // decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Login View ────────────────────────────────────────────────────────────

  Widget _buildLoginView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Icon
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              HugeIcons.strokeRoundedCloud,
              size: 70,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Keep your tasks safe',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: context.primaryFontColor,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in with Google to enable cloud backup and never lose your progress again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: context.secondaryFontColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 50),

          // Google Login Button
          InkWell(
            onTap: () => context.read<AuthCubit>().signInWithGoogle(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.inputBorderColor.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/google.png', width: 24, height: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: context.primaryFontColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'By continuing, you agree to our terms of service.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: context.secondaryFontColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Components ────────────────────────────────────────────────────────────

  Widget _buildPremiumCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.inputBorderColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.secondaryFontColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(SyncStatus status) {
    Color color = _syncColor(status);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(_syncIcon(status), color: color, size: 24),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: Text(label),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  IconData _syncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.check_circle_outline_rounded;
      case SyncStatus.syncing:
        return Icons.sync_rounded;
      case SyncStatus.error:
        return Icons.error_outline_rounded;
      case SyncStatus.offline:
        return Icons.wifi_off_rounded;
      default:
        return Icons.cloud_queue_rounded;
    }
  }

  Color _syncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return AppColors.success;
      case SyncStatus.syncing:
        return AppColors.primaryColor;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.offline:
        return Colors.orange;
      default:
        return AppColors.primaryColor;
    }
  }

  String _syncLabel(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Status: Secured';
      case SyncStatus.syncing:
        return 'Syncing Data...';
      case SyncStatus.error:
        return 'Connection Failed';
      case SyncStatus.offline:
        return 'Internet Disconnected';
      default:
        return 'Ready to Sync';
    }
  }
}
