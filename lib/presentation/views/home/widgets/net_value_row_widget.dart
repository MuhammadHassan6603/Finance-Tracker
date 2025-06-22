import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/session_manager.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';

class NetValueRowWidget extends StatelessWidget {
  const NetValueRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AssetLiabilityViewModel>();
    final currencyCode = context.watch<SessionManager>().selectedCurrency;
    final localization = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeaderText(
                text: '${localization.netWorth}: $currencyCode${vm.netWorth}',
                fontSize: 20),
            // Text(
            //   '▲ ${Helpers.formatCurrency(vm.totalAssets)} Assets'
            //   ' ▼ ${Helpers.formatCurrency(vm.totalLiabilities)} Liabilities',
            //   style: Theme.of(context).textTheme.bodyMedium,
            // ),
          ],
        ),
        _buildLoadingOrRefresh(vm),
      ],
    );
  }

  Widget _buildLoadingOrRefresh(AssetLiabilityViewModel vm) {
    return vm.isLoading
        ? const CircularProgressIndicator()
        : IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: vm.reloadItems,
            tooltip: 'Refresh Net Worth',
          );
  }
}
