class AdHelper {
  static const bool isTest = false;

  static String get rewardedAdUnitId {
    if (isTest) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else {
      return "ca-app-pub-9221751274718386/7787113026";
    }
  }

  static String get interstitialAdUnitId {
    if (isTest) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else {
      return "ca-app-pub-9221751274718386/3678300485";
    }
  }
}
