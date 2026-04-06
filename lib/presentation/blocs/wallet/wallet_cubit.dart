import 'package:clear_task/data/models/user_wallet_model.dart';
import 'package:clear_task/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState {
  final WalletStatus status;
  final UserWalletModel? wallet;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    UserWalletModel? wallet,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      errorMessage: errorMessage,
    );
  }
}

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository = WalletRepository();

  WalletCubit() : super(const WalletState());

  /// Fetch user wallet data (initial or sync)
  Future<void> fetchWallet(String userId) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      final wallet = await _repository.getWallet(userId);
      emit(state.copyWith(status: WalletStatus.loaded, wallet: wallet));
    } catch (e) {
      emit(state.copyWith(status: WalletStatus.error, errorMessage: e.toString()));
    }
  }

  /// Claim daily reward
  Future<bool> claimDailyReward(String userId) async {
    try {
      final success = await _repository.claimDailyReward(userId);
      if (success) {
        // Refresh state
        await fetchWallet(userId);
      }
      return success;
    } catch (e) {
      print('❌ Daily reward claim failed silently in Cubit: $e');
      return false;
    }
  }

  /// Reward coins from ad
  Future<void> rewardFromAd(String userId, int amount) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      await _repository.addCoins(userId, amount);
      await fetchWallet(userId);
    } catch (e) {
      emit(state.copyWith(status: WalletStatus.error, errorMessage: 'Failed to add coins from ad: $e'));
    }
  }

  /// Spend coins
  Future<bool> spendCoins(String userId, int amount) async {
    try {
      final success = await _repository.spendCoins(userId, amount);
      if (success) {
        await fetchWallet(userId);
        return true;
      }
      return false;
    } catch (e) {
      emit(state.copyWith(status: WalletStatus.error, errorMessage: 'Failed to spend coins: $e'));
      return false;
    }
  }

  /// Clear local cache (on logout)
  Future<void> clearCache() async {
    await _repository.clearCache();
    emit(const WalletState());
  }
}
