class AdHelper {
  static const bool isTest = true;

  static String get bannerAdUnitId {
    if (isTest) {
      return "ca-app-pub-3940256099942544/6300978111";
    } else {
      return "ca-app-pub-9221751274718386/1539621680";
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
