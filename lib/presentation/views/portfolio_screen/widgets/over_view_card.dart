import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/portfolio_screen/widgets/over_view_header_widget.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/theme_constants.dart';
import 'assets_liability_cart.dart';
import 'net_worth_display_widget.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppHeaderText(
                text: AppLocalizations.of(context).overview, fontSize: 20),
            const OverviewHeader(),
            const Gap(8),
            const NetWorthDisplay(),
            const Gap(16),
            const AssetsLiabilityCart(),
          ],
        ),
      ),
    );
  }
}
