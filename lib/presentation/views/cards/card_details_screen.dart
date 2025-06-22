import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../data/models/account_card_model.dart';
import '../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../data/models/asset_liability_model.dart';
import 'add_card_sheet.dart';

class CardDetailsScreen extends StatefulWidget {
  final AccountCardModel card;

  const CardDetailsScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  bool _isRepayLoading = false;
  late AccountCardModel _card;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final card = _card;
    final assetLiabilityVM = context.watch<AssetLiabilityViewModel>();

    // Only show repayment section for credit cards
    final isCreditCard = card.type == 'Credit Card';
    List<AssetLiabilityModel> cardLiabilities = [];
    double totalToRepay = 0;
    double totalRepaid = 0;

    if (isCreditCard) {
      cardLiabilities = assetLiabilityVM.liabilities
          .where((l) => l.type == 'Credit Card' && l.cardId == card.id && l.isActive)
          .toList();
      totalToRepay = cardLiabilities.fold(0.0, (sum, l) => sum + l.amount);
      // Calculate repaid as sum of all history entries for this card's liabilities
      totalRepaid = cardLiabilities.fold(0.0, (sum, l) {
        if (l.history.isEmpty) return sum;
        final paid = l.history.fold<double>(0.0, (hSum, entry) {
          final oldAmount = (entry['amount'] as num?)?.toDouble() ?? 0.0;
          // If amount decreased, it's a repayment
          final diff = (l.amount < oldAmount) ? (oldAmount - l.amount) : 0.0;
          return hSum + diff;
        });
        return sum + paid;
      });
    }

    return Scaffold(
      appBar: SharedAppbar(
        title: card.name,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2_bold),
            onPressed: () => _editCard(context),
          ),
          IconButton(
            icon: const Icon(Iconsax.card_remove_1_bold),
            onPressed: () => _deleteCard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardPreview(),
            const SizedBox(height: 20,),
            _buildCardDetails(context),
            if (isCreditCard) ...[
              const SizedBox(height: 24),
              _buildRepaymentSection(context, totalToRepay, totalRepaid, cardLiabilities),
            ],
            // _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    final card = _card;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: card.color.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(card.icon, color: card.color),
              Text(
                card.type,
                style: TextStyle(
                  color: card.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            card.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.number,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '₹${card.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              card.accountName,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardDetails(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final card = _card;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeaderText(
              text: AppLocalizations.of(context).cardDetails, fontSize: 20),
          const SizedBox(height: 16),
          _buildDetailRow(localizations.typeLabel, card.type),
          _buildDetailRow(localizations.name, card.name),
          _buildDetailRow(localizations.accountName, card.accountName),
          _buildDetailRow(localizations.number, card.number),
          _buildDetailRow(localizations.balanceLabel,
              '${Helpers.storeCurrency(context)}${card.balance.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentSection(BuildContext context, double totalToRepay, double totalRepaid, List<AssetLiabilityModel> cardLiabilities) {
    final local = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.repayment, style: Theme.of(context).textTheme.titleMedium),
                Icon(Iconsax.card_bold, color: Theme.of(context).primaryColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.amountToRepay, style: Theme.of(context).textTheme.bodyMedium),
                Text('${Helpers.storeCurrency(context)}${totalToRepay.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.amountRepaid, style: Theme.of(context).textTheme.bodyMedium),
                Text('${Helpers.storeCurrency(context)}${totalRepaid.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: totalToRepay > 0 && !_isRepayLoading
                    ? () => _showRepayDialog(context, cardLiabilities, totalToRepay)
                    : null,
                child: _isRepayLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(local.payNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepayDialog(BuildContext context, List<AssetLiabilityModel> cardLiabilities, double maxAmount) {
  final local = AppLocalizations.of(context);
  final controller = TextEditingController();
  String? errorText;
  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(local.repayCreditCard),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${local.amountToRepay}: ${Helpers.storeCurrency(context)}${maxAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: local.enterAmount,
                    hintText: local.enterAmount,
                  ),
                  onChanged: (_) {
                    if (errorText != null) {
                      setDialogState(() => errorText = null);
                    }
                  },
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(local.cancel),
              ),
              ElevatedButton(
                onPressed: (maxAmount <= 0)
                    ? null
                    : () async {
                        final entered = double.tryParse(controller.text) ?? 0.0;
                        if (entered <= 0) {
                          setDialogState(() => errorText = local.pleaseEnterAValidAmount);
                          return;
                        }
                        if (entered > maxAmount) {
                          setDialogState(() => errorText = local.amountExceedsRepay);
                          return;
                        }
                        
                        // Store the parent context before closing dialog
                        final parentContext = this.context;
                        
                        Navigator.pop(dialogContext);
                        setState(() => _isRepayLoading = true);
                        await _handleRepayment(parentContext, cardLiabilities, entered);
                        if (mounted) setState(() => _isRepayLoading = false);
                        
                        // Use parentContext instead of context for the toast
                        if (parentContext.mounted) {
                          ToastUtils.showSuccessToast(parentContext, 
                            title: local.success, 
                            description: local.repaymentSuccessful);
                        }
                        // Refresh the card data from the viewmodel to update the UI
                        final accountCardVM = parentContext.read<AccountCardViewModel>();
                        final updatedCard = accountCardVM.accountCards.firstWhere(
                          (c) => c.id == widget.card.id,
                          orElse: () => widget.card,
                        );
                        if (mounted) setState(() {
                          _card = updatedCard;
                        });
                      },
                child: Text(local.pay),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _handleRepayment(BuildContext context, List<AssetLiabilityModel> cardLiabilities, double repayAmount) async {
    final assetLiabilityVM = context.read<AssetLiabilityViewModel>();
    final accountCardVM = context.read<AccountCardViewModel>();
    double remaining = repayAmount;
    for (final liability in cardLiabilities) {
      if (remaining <= 0) break;
      final pay = remaining > liability.amount ? liability.amount : remaining;
      final newAmount = liability.amount - pay;
      final updated = liability.recordHistory(newAmount >= 0 ? newAmount : 0);
      await assetLiabilityVM.updateAssetLiability(updated);
      remaining -= pay;
    }
    final card = widget.card;
    final updatedCard = card.copyWith(balance: card.balance + repayAmount);
    await accountCardVM.updateAccountCard(updatedCard);
    if (mounted) setState(() {});
  }

  void _editCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCardSheet(
        card: widget.card,
        isEditing: true,
      ),
    );
  }

  void _deleteCard(BuildContext context) {
    final viewModel = context.read<AccountCardViewModel>();
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(localizations.deleteCard),
        content: Text(localizations.areYouSureYouWantToDeleteThisCard),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              // First pop the dialog
              Navigator.pop(dialogContext);

              try {
                // Delete the card
                await viewModel.deleteAccountCard(widget.card.id);

                // Check if the widget is still mounted before showing toast and popping
                if (context.mounted) {
                  // Show success toast
                  ToastUtils.showSuccessToast(context,
                      title: localizations.deleted,
                      description: localizations.cardDeletedSuccessfully);

                  // Pop the card details screen
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showErrorToast(context,
                      title: localizations.error,
                      description: 'Failed to delete card: ${e.toString()}');
                }
              }
            },
            child: Text(
              localizations.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
