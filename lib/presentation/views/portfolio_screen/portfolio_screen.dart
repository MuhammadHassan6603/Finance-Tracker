import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/portfolio_screen/widgets/assets_laibilities_section.dart';
import 'package:finance_tracker/presentation/views/portfolio_screen/widgets/over_view_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../widgets/app_header_text.dart';
import '../../../widgets/line_chart_widget.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final GlobalKey<AssetsLiabilitiesSectionState> _sectionKey = GlobalKey();

  bool get isAssetTabSelected =>
      _sectionKey.currentState?.selectedTabIndex == 0;

  @override
  Widget build(BuildContext context) {
    final assetVM = context.watch<AssetLiabilityViewModel>();
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OverviewCard(),
            const Gap(16),
            AppHeaderText(
                text: AppLocalizations.of(context).growthTrend, fontSize: 18),
            const Gap(16),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                netWorthHistory: assetVM.netWorthHistory
                    .map((h) => FlSpot(h.date.month.toDouble(), h.amount))
                    .toList(),
              ),
            ),
            const Gap(16),
            AssetsLiabilitiesSection(
              key: _sectionKey,
              onAssetAmountChanged: _handleAssetAmountChange,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAssetAmountChange(String assetId, double newAmount) async {
    final accountVM = context.read<AccountCardViewModel>();

    try {
      // Find the card linked to this bank asset
      final linkedCard = accountVM.accountCards.firstWhere(
        (card) => card.linkedBankAssetId == assetId,
      );

      // Update the card's balance to match the new asset amount
      await accountVM.updateAccountCard(
        linkedCard.copyWith(balance: newAmount),
      );
    } catch (e) {
      // No linked card found, ignore the error
      debugPrint('No card linked to bank asset $assetId');
    }
  }
}
