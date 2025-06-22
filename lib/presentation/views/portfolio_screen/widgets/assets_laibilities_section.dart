import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_asset_liability_dialog.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../viewmodels/account_card_viewmodel.dart';
import '../../../../data/models/asset_liability_model.dart';

class AssetsLiabilitiesSection extends StatefulWidget {
  final Function(String, double)? onAssetAmountChanged;

  const AssetsLiabilitiesSection({
    super.key,
    this.onAssetAmountChanged,
  });

  @override
  AssetsLiabilitiesSectionState createState() => AssetsLiabilitiesSectionState();
}

class AssetsLiabilitiesSectionState extends State<AssetsLiabilitiesSection> {
  int _selectedTabIndex = 0;

  // Public getter for _selectedTabIndex
  int get selectedTabIndex => _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<AssetLiabilityViewModel>(context, listen: false);
      if (viewModel.items.isEmpty) {
        viewModel.loadAssetLiabilities();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Text('Error: ${viewModel.error}');
        }

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTab('Assets', 0),
                  _buildTab('Liabilities', 1),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List content
            _selectedTabIndex == 0
                ? _buildAssetsList(viewModel.assets)
                : _buildLiabilitiesList(viewModel.liabilities),
          ],
        );
      },
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return Builder(builder: (context) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTabIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? isDarkMode
                      ? ThemeConstants.cardDark
                      : Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.shade300,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? isDarkMode
                            ? ThemeConstants.textPrimaryDark
                            : Colors.black87
                        : isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAssetsList(List<AssetLiabilityModel> assets) {
    return Column(
      children: assets.map((asset) => _buildListItem(asset)).toList(),
    );
  }

  Widget _buildLiabilitiesList(List<AssetLiabilityModel> liabilities) {
    return Column(
      children:
          liabilities.map((liability) => _buildListItem(liability)).toList(),
    );
  }

  Future<void> _showEditDialog(AssetLiabilityModel item) async {
    final result = await showDialog<AssetLiabilityModel>(
      context: context,
      builder: (context) => EditAssetLiabilityDialog(item: item),
    );

    if (result != null && mounted) {
      final viewModel =
          Provider.of<AssetLiabilityViewModel>(context, listen: false);
      final success = await viewModel.updateAssetLiability(result);

      if (success && mounted) {
        // If this is a bank asset and its amount has changed, notify the parent
        if (item.type == 'Bank' && result.amount != item.amount) {
          widget.onAssetAmountChanged?.call(result.id, result.amount);
        }

        ToastUtils.showSuccessToast(context,
            title: 'Updated', description: '${item.name} updated successfully');
      }
    }
  }

  Future<void> _showDeleteDialog(AssetLiabilityModel item) async {
    final local = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item.isAsset ? 'Asset' : 'Liability'}'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              local.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final viewModel = Provider.of<AssetLiabilityViewModel>(context, listen: false);
      final accountVM = Provider.of<AccountCardViewModel>(context, listen: false);

      // If this is a bank asset, find and unlink any associated card
      if (item.type == 'Bank') {
        try {
          final linkedCard = accountVM.accountCards.firstWhere(
            (card) => card.linkedBankAssetId == item.id,
          );
          
          // Unlink the card by setting linkedBankAssetId to null
          // Keep the card's current balance when unlinking
          await accountVM.updateAccountCard(
            linkedCard.copyWith(
              linkedBankAssetId: null,
              // Keep the current balance when unlinking
              balance: linkedCard.balance,
            ),
          );
        } catch (e) {
          // No linked card found, ignore the error
          debugPrint('No card linked to bank asset ${item.id}');
        }
      }

      // Delete the asset/liability
      final success = await viewModel.deleteAssetLiability(item.id);

      if (success && mounted) {
        ToastUtils.showSuccessToast(
          context,
          title: 'Deleted',
          description: '${item.name} deleted successfully',
        );
      }
    }
  }

  Widget _buildListItem(AssetLiabilityModel item) {
    final local = AppLocalizations.of(context);
    return Builder(builder: (context) {
      final viewModel =
          Provider.of<AssetLiabilityViewModel>(context, listen: false);
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? ThemeConstants.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            item.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode
                      ? ThemeConstants.textPrimaryDark
                      : ThemeConstants.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(4),
              Text(
                item.type,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
              ),
              const Gap(4),
              Text(
                '${Helpers.storeCurrency(context)}${item.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: item.isAsset
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => _showDeleteDialog(item),
              ),
            ],
          ),
        ),
      );
    });
  }
}
