import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PomodoroPhase { idle, focusing, shortBreak, longBreak }

class PomodoroState {
  final PomodoroPhase phase;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedPomodoros;
  final bool isPaused;

  // User-configurable durations (in minutes)
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.completedPomodoros = 0,
    this.isPaused = false,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
  });

  double get progress =>
      totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get phaseLabel {
    switch (phase) {
      case PomodoroPhase.idle:
        return 'Ready to Focus';
      case PomodoroPhase.focusing:
        return 'Stay Focused';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  String get phaseEmoji {
    switch (phase) {
      case PomodoroPhase.idle:
        return '🎯';
      case PomodoroPhase.focusing:
        return '🔥';
      case PomodoroPhase.shortBreak:
        return '☕';
      case PomodoroPhase.longBreak:
        return '🌿';
    }
  }

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedPomodoros,
    bool? isPaused,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isPaused: isPaused ?? this.isPaused,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    );
  }
}

class PomodoroCubit extends Cubit<PomodoroState> {
  static const String _focusKey = 'pomodoro_focus_min';
  static const String _shortBreakKey = 'pomodoro_short_break_min';
  static const String _longBreakKey = 'pomodoro_long_break_min';
  static const int longBreakInterval = 4;

  Timer? _timer;

  PomodoroCubit() : super(const PomodoroState()) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final focus = prefs.getInt(_focusKey) ?? 25;
    final shortB = prefs.getInt(_shortBreakKey) ?? 5;
    final longB = prefs.getInt(_longBreakKey) ?? 15;
    emit(state.copyWith(
      focusMinutes: focus,
      shortBreakMinutes: shortB,
      longBreakMinutes: longB,
      remainingSeconds: focus * 60,
      totalSeconds: focus * 60,
    ));
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusKey, state.focusMinutes);
    await prefs.setInt(_shortBreakKey, state.shortBreakMinutes);
    await prefs.setInt(_longBreakKey, state.longBreakMinutes);
  }

  // ── Duration setters (only while idle) ───────────────────────────────────

  void setFocusMinutes(int min) {
    if (state.phase != PomodoroPhase.idle) return;
    emit(state.copyWith(
      focusMinutes: min,
      remainingSeconds: min * 60,
      totalSeconds: min * 60,
    ));
    _savePrefs();
  }

  void setShortBreakMinutes(int min) {
    if (state.phase != PomodoroPhase.idle) return;
    emit(state.copyWith(shortBreakMinutes: min));
    _savePrefs();
  }

  void setLongBreakMinutes(int min) {
    if (state.phase != PomodoroPhase.idle) return;
    emit(state.copyWith(longBreakMinutes: min));
    _savePrefs();
  }

  // ── Timer controls ───────────────────────────────────────────────────────

  void start() {
    if (state.phase == PomodoroPhase.idle) {
      final secs = state.focusMinutes * 60;
      emit(state.copyWith(
        phase: PomodoroPhase.focusing,
        remainingSeconds: secs,
        totalSeconds: secs,
        isPaused: false,
      ));
    } else if (state.isPaused) {
      emit(state.copyWith(isPaused: false));
    }
    _startTicking();
  }

  void pause() {
    _timer?.cancel();
    emit(state.copyWith(isPaused: true));
  }

  void reset() {
    _timer?.cancel();
    final secs = state.focusMinutes * 60;
    emit(PomodoroState(
      focusMinutes: state.focusMinutes,
      shortBreakMinutes: state.shortBreakMinutes,
      longBreakMinutes: state.longBreakMinutes,
      remainingSeconds: secs,
      totalSeconds: secs,
    ));
  }

  void skipToNext() {
    _timer?.cancel();
    _onPhaseComplete();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        _onPhaseComplete();
      } else {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      }
    });
  }

  void _onPhaseComplete() {
    if (state.phase == PomodoroPhase.focusing) {
      final newCount = state.completedPomodoros + 1;
      final isLongBreak = newCount % longBreakInterval == 0;
      final breakMin =
          isLongBreak ? state.longBreakMinutes : state.shortBreakMinutes;
      final breakPhase =
          isLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      final secs = breakMin * 60;

      emit(state.copyWith(
        phase: breakPhase,
        remainingSeconds: secs,
        totalSeconds: secs,
        completedPomodoros: newCount,
        isPaused: false,
      ));
      _startTicking();
    } else {
      final secs = state.focusMinutes * 60;
      emit(state.copyWith(
        phase: PomodoroPhase.focusing,
        remainingSeconds: secs,
        totalSeconds: secs,
        isPaused: false,
      ));
      _startTicking();
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
