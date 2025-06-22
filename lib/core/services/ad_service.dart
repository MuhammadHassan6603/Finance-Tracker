import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static const testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  static const bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
// AdService is a singleton class that handles the initialization and configuration of Google Mobile Ads SDK.
}
