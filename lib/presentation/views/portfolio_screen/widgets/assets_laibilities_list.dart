import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../core/constants/theme_constants.dart';

class AssetLiabilitiesList extends StatelessWidget {
  const AssetLiabilitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final topAssets = viewModel.assets.take(3).toList();
        final topLiabilities = viewModel.liabilities.take(3).toList();
        final local = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('${local.topAssets}:', topAssets, isDarkMode),
              const SizedBox(height: 8),
              ..._buildListItems(topAssets, context),
              const SizedBox(height: 16),
              _buildSectionTitle(
                  '${local.topLiabilities}:', topLiabilities, isDarkMode),
              const SizedBox(height: 8),
              ..._buildListItems(topLiabilities, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String text, List items, bool isDarkMode) {
    return Text(
      items.isEmpty ? '$text None' : text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDarkMode
            ? ThemeConstants.textPrimaryDark
            : ThemeConstants.textPrimaryLight,
      ),
    );
  }

  List<Widget> _buildListItems(List<dynamic> items, BuildContext context) {
    return items
        .map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('• ',
                      style: TextStyle(
                        color: item.isAsset ? Colors.green : Colors.red,
                      )),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isAsset ? Colors.green : Colors.red,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${Helpers.storeCurrency(context)}${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: item.isAsset ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
