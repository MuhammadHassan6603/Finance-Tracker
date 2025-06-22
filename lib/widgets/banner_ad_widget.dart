import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../viewmodels/ad_service_viewmodel.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adViewModel = context.watch<AdViewModel>();

    if (!adViewModel.isBannerAdLoaded || adViewModel.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: adViewModel.bannerAd!.size.width.toDouble(),
      height: adViewModel.bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: adViewModel.bannerAd!),
    );
  }
}
