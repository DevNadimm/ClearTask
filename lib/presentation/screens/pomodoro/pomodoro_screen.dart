import 'dart:math';
import 'package:clear_task/core/constants/colors.dart';
import 'package:clear_task/presentation/blocs/pomodoro/pomodoro_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PomodoroCubit(),
      child: const _PomodoroBody(),
    );
  }
}

class _PomodoroBody extends StatefulWidget {
  const _PomodoroBody();

  @override
  State<_PomodoroBody> createState() => _PomodoroBodyState();
}

class _PomodoroBodyState extends State<_PomodoroBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _phaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.idle:
        return AppColors.primaryColor;
      case PomodoroPhase.focusing:
        return const Color(0xFFFF6B6B);
      case PomodoroPhase.shortBreak:
        return const Color(0xFF4ECDC4);
      case PomodoroPhase.longBreak:
        return const Color(0xFF45B7D1);
    }
  }

  Color _phaseGlowColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.idle:
        return AppColors.primaryColor.withValues(alpha: 0.25);
      case PomodoroPhase.focusing:
        return const Color(0xFFFF6B6B).withValues(alpha: 0.3);
      case PomodoroPhase.shortBreak:
        return const Color(0xFF4ECDC4).withValues(alpha: 0.25);
      case PomodoroPhase.longBreak:
        return const Color(0xFF45B7D1).withValues(alpha: 0.25);
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
        title: const Text('Focus Timer'),
        actions: [
          BlocBuilder<PomodoroCubit, PomodoroState>(
            builder: (context, state) {
              if (state.phase != PomodoroPhase.idle) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Settings',
                onPressed: () => _showSettingsSheet(context),
                icon: Icon(
                  HugeIcons.strokeRoundedSettings01,
                  color: context.primaryFontColor,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PomodoroCubit, PomodoroState>(
        builder: (context, state) {
          final cubit = context.read<PomodoroCubit>();
          final color = _phaseColor(state.phase);
          final isRunning =
              state.phase != PomodoroPhase.idle && !state.isPaused;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Phase chips ─────────────────────────────────────────
                  _PhaseChips(currentPhase: state.phase),

                  const SizedBox(height: 8),

                  // ── Phase label + emoji ─────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      key: ValueKey(state.phaseLabel),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.phaseEmoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Text(
                          state.phaseLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Circular timer ──────────────────────────────────────
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final pulse = isRunning
                          ? 1.0 + (_pulseController.value * 0.015)
                          : 1.0;
                      return Transform.scale(scale: pulse, child: child);
                    },
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _phaseGlowColor(state.phase),
                            blurRadius: 60,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer decorative ring
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 4,
                              color: context.inputBorderColor
                                  .withValues(alpha: 0.12),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          // Main progress ring
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                  begin: state.progress, end: state.progress),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, value, _) {
                                return Transform.rotate(
                                  angle: -pi / 2,
                                  child: CustomPaint(
                                    painter: _GradientRingPainter(
                                      progress: value,
                                      color: color,
                                      strokeWidth: 12,
                                      bgColor: context.inputBorderColor
                                          .withValues(alpha: 0.15),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Inner frosted circle
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.cardColor.withValues(alpha: 0.7),
                              border: Border.all(
                                color: context.inputBorderColor
                                    .withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w700,
                                    color: context.primaryFontColor,
                                    letterSpacing: 3,
                                    height: 1.1,
                                  ),
                                ),
                                if (state.phase == PomodoroPhase.idle)
                                  Text(
                                    '${state.focusMinutes} min session',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: context.secondaryFontColor,
                                    ),
                                  ),
                                if (state.phase != PomodoroPhase.idle)
                                  TextButton(
                                    onPressed: () => cubit.skipToNext(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Skip',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: context.secondaryFontColor,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          HugeIcons.strokeRoundedArrowRight01,
                                          size: 14,
                                          color: context.secondaryFontColor,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Controls ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset
                      if (state.phase != PomodoroPhase.idle) ...[
                        _ControlButton(
                          icon: HugeIcons.strokeRoundedRefresh,
                          label: 'Reset',
                          color: context.secondaryFontColor,
                          onTap: () => cubit.reset(),
                        ),
                        const SizedBox(width: 40),
                      ],

                      // Play / Pause
                      GestureDetector(
                        onTap: () {
                          if (state.phase == PomodoroPhase.idle ||
                              state.isPaused) {
                            cubit.start();
                          } else {
                            cubit.pause();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRunning
                                ? HugeIcons.strokeRoundedPause
                                : HugeIcons.strokeRoundedPlay,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ── Pomodoro count dots ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.inputBorderColor,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sessions Completed',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.secondaryFontColor,
                          ),
                        ),
                        if (state.completedPomodoros.clamp(0, 12) > 0) const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            state.completedPomodoros.clamp(0, 12),
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.check,
                                    size: 10, color: Colors.white),
                              ),
                            ),
                          )..addAll(
                              List.generate(
                                (4 - (state.completedPomodoros % 4)) % 4,
                                (i) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.inputBorderColor
                                            .withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ),
                        if (state.completedPomodoros > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${state.completedPomodoros} 🔥',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: context.primaryFontColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Duration config chips (only in idle) ────────────────
                  if (state.phase == PomodoroPhase.idle) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.inputBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Duration',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.secondaryFontColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [15, 25, 30, 45, 60].map((min) {
                              final isSelected = state.focusMinutes == min;
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: GestureDetector(
                                    onTap: () => cubit.setFocusMinutes(min),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color.withValues(alpha: 0.2)
                                            : context.inputBorderColor
                                                .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected
                                            ? Border.all(
                                                color: color, width: 1.5)
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${min}m',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? color
                                                : context.secondaryFontColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Settings bottom sheet ───────────────────────────────────────────────────

  void _showSettingsSheet(BuildContext context) {
    final cubit = context.read<PomodoroCubit>();
    final state = cubit.state;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        return _SettingsSheet(
          focusMin: state.focusMinutes,
          shortBreakMin: state.shortBreakMinutes,
          longBreakMin: state.longBreakMinutes,
          onFocusChanged: (v) => cubit.setFocusMinutes(v),
          onShortBreakChanged: (v) => cubit.setShortBreakMinutes(v),
          onLongBreakChanged: (v) => cubit.setLongBreakMinutes(v),
        );
      },
    );
  }
}

// ── Phase indicator chips ───────────────────────────────────────────────────────

class _PhaseChips extends StatelessWidget {
  final PomodoroPhase currentPhase;

  const _PhaseChips({required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Focus', PomodoroPhase.focusing, const Color(0xFFFF6B6B)),
      ('Short Break', PomodoroPhase.shortBreak, const Color(0xFF4ECDC4)),
      ('Long Break', PomodoroPhase.longBreak, const Color(0xFF45B7D1)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          final isActive = currentPhase == item.$2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? item.$3.withValues(alpha: 0.2)
                    : context.inputBorderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border:
                    isActive ? Border.all(color: item.$3, width: 1.2) : null,
              ),
              child: Text(
                item.$1,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? item.$3 : context.secondaryFontColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Control button ──────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

// ── Settings bottom sheet ───────────────────────────────────────────────────────

class _SettingsSheet extends StatefulWidget {
  final int focusMin;
  final int shortBreakMin;
  final int longBreakMin;
  final ValueChanged<int> onFocusChanged;
  final ValueChanged<int> onShortBreakChanged;
  final ValueChanged<int> onLongBreakChanged;

  const _SettingsSheet({
    required this.focusMin,
    required this.shortBreakMin,
    required this.longBreakMin,
    required this.onFocusChanged,
    required this.onShortBreakChanged,
    required this.onLongBreakChanged,
  });

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _focus;
  late int _shortBreak;
  late int _longBreak;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusMin;
    _shortBreak = widget.shortBreakMin;
    _longBreak = widget.longBreakMin;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: context.secondaryFontColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Timer Settings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.primaryFontColor,
            ),
          ),
          const SizedBox(height: 24),
          _DurationSlider(
            label: 'Focus Duration',
            emoji: '🔥',
            value: _focus,
            min: 5,
            max: 90,
            color: const Color(0xFFFF6B6B),
            onChanged: (v) {
              setState(() => _focus = v);
              widget.onFocusChanged(v);
            },
          ),
          const SizedBox(height: 20),
          _DurationSlider(
            label: 'Short Break',
            emoji: '☕',
            value: _shortBreak,
            min: 1,
            max: 30,
            color: const Color(0xFF4ECDC4),
            onChanged: (v) {
              setState(() => _shortBreak = v);
              widget.onShortBreakChanged(v);
            },
          ),
          const SizedBox(height: 20),
          _DurationSlider(
            label: 'Long Break',
            emoji: '🌿',
            value: _longBreak,
            min: 5,
            max: 60,
            color: const Color(0xFF45B7D1),
            onChanged: (v) {
              setState(() => _longBreak = v);
              widget.onLongBreakChanged(v);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Long break triggers every 4 sessions',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: context.secondaryFontColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Duration slider row ─────────────────────────────────────────────────────────

class _DurationSlider extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  const _DurationSlider({
    required this.label,
    required this.emoji,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.primaryFontColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$value min',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

// ── Gradient ring painter ───────────────────────────────────────────────────────

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color bgColor;

  _GradientRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // Progress ring with gradient
    if (progress > 0) {
      final gradient = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi * progress,
        colors: [
          color.withValues(alpha: 0.6),
          color,
        ],
      );
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, 0, 2 * pi * progress, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
