import 'package:clear_task/data/services/premium_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class PremiumState {
  final int weeklyUsageCount;
  final int bonusUses;
  final int maxFreeUses;
  final bool isLoading;

  const PremiumState({
    this.weeklyUsageCount = 0,
    this.bonusUses = 0,
    this.maxFreeUses = PremiumService.maxFreeUsesPerWeek,
    this.isLoading = true,
  });

  int get totalAllowed => maxFreeUses + bonusUses;
  int get remainingUses => (totalAllowed - weeklyUsageCount).clamp(0, totalAllowed);
  bool get canUseAi => remainingUses > 0;

  PremiumState copyWith({
    int? weeklyUsageCount,
    int? bonusUses,
    int? maxFreeUses,
    bool? isLoading,
  }) {
    return PremiumState(
      weeklyUsageCount: weeklyUsageCount ?? this.weeklyUsageCount,
      bonusUses: bonusUses ?? this.bonusUses,
      maxFreeUses: maxFreeUses ?? this.maxFreeUses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class PremiumCubit extends Cubit<PremiumState> {
  final PremiumService _service = PremiumService();

  PremiumCubit() : super(const PremiumState()) {
    loadStatus();
  }

  /// Load current premium status and usage from local storage.
  Future<void> loadStatus() async {
    emit(state.copyWith(isLoading: true));
    final usage = await _service.getWeeklyUsageCount();
    final bonus = await _service.getBonusUses();
    emit(state.copyWith(
      weeklyUsageCount: usage,
      bonusUses: bonus,
      isLoading: false,
    ));
  }

  /// Call before each AI use. Returns true if allowed.
  Future<bool> tryUseAi() async {
    if (!state.canUseAi) return false;

    await _service.incrementUsage();
    emit(state.copyWith(weeklyUsageCount: state.weeklyUsageCount + 1));
    return true;
  }

  /// Grant bonus uses (e.g. after watching a rewarded ad).
  Future<void> grantBonusUses(int count) async {
    await _service.grantBonusUses(count);
    emit(state.copyWith(bonusUses: state.bonusUses + count));
  }
}
