import 'package:clear_task/data/models/user_credit_model.dart';
import 'package:clear_task/data/repositories/credit_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CreditStatus { initial, loading, loaded, error }

class CreditState {
  final CreditStatus status;
  final UserCreditModel? credit;
  final String? errorMessage;

  const CreditState({
    this.status = CreditStatus.initial,
    this.credit,
    this.errorMessage,
  });

  CreditState copyWith({
    CreditStatus? status,
    UserCreditModel? credit,
    String? errorMessage,
  }) {
    return CreditState(
      status: status ?? this.status,
      credit: credit ?? this.credit,
      errorMessage: errorMessage,
    );
  }
}

class CreditCubit extends Cubit<CreditState> {
  final CreditRepository _repository = CreditRepository();

  CreditCubit() : super(const CreditState());

  /// Fetch user credit data (initial or sync)
  Future<void> fetchCredit(String userId) async {
    emit(state.copyWith(status: CreditStatus.loading));
    try {
      final credit = await _repository.getCredit(userId);
      emit(state.copyWith(status: CreditStatus.loaded, credit: credit));
    } catch (e) {
      emit(state.copyWith(status: CreditStatus.error, errorMessage: e.toString()));
    }
  }

  /// Check and grant daily credit
  Future<void> checkAndGrantDaily(String userId) async {
    try {
      final success = await _repository.checkAndGrantDaily(userId);
      if (success) {
        // Refresh state
        await fetchCredit(userId);
      }
    } catch (e) {
      // Just log, Don't block UI if daily grant fails
      print('❌ Daily grant failed silently in Cubit: $e');
    }
  }

  /// Reward credit from ad
  Future<void> rewardFromAd(String userId, int amount) async {
    emit(state.copyWith(status: CreditStatus.loading));
    try {
      await _repository.addAdReward(userId, amount);
      await fetchCredit(userId);
    } catch (e) {
      emit(state.copyWith(status: CreditStatus.error, errorMessage: 'Failed to add credit: $e'));
    }
  }

  /// Spend credit
  Future<bool> spendCredit(String userId, int amount) async {
    try {
      final success = await _repository.spend(userId, amount);
      if (success) {
        await fetchCredit(userId);
        return true;
      }
      return false;
    } catch (e) {
      emit(state.copyWith(status: CreditStatus.error, errorMessage: 'Failed to spend credit: $e'));
      return false;
    }
  }

  /// Clear local cache (on logout)
  Future<void> clearCache() async {
    await _repository.clearCache();
    emit(const CreditState());
  }
}
