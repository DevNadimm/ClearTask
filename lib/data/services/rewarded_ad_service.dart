import 'package:clear_task/core/utils/helper_functions/ad_helper.dart';
import 'package:clear_task/presentation/blocs/wallet/wallet_cubit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages loading and showing rewarded ads for bonus AI uses.
class RewardedAdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  /// Preload a rewarded ad. Call on app startup.
  static void preload() {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Returns true if an ad is ready to show.
  static bool get isReady => _rewardedAd != null;

  /// Shows the rewarded ad. Calls [onReward] when the user earns the reward.
  /// Calls [onAdDismissed] when the ad is closed (regardless of reward).
  static void show({
    required String userId,
    required WalletCubit walletCubit,
    void Function()? onRewardSuccess,
    void Function()? onAdDismissed,
    void Function()? onAdNotReady,
  }) {
    if (_rewardedAd == null) {
      onAdNotReady?.call();
      preload(); // Try loading again
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        preload(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        preload();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // Grant 15 coins for watching the ad
        walletCubit.rewardFromAd(userId, 15);
        onRewardSuccess?.call();
      },
    );
  }
}
