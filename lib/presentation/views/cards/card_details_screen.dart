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
import 'package:uuid/uuid.dart';
import '../../../data/models/transaction_model.dart';
import '../../../viewmodels/transaction_viewmodel.dart';
import 'package:collection/collection.dart';
import 'credit_card_statements_screen.dart';

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
      // Calculate repaid as sum of all repayments (positive increases in amount in history)
      totalRepaid = cardLiabilities.fold(0.0, (sum, l) {
        if (l.history.length < 2) return sum;
        double repaid = 0.0;
        for (int i = 1; i < l.history.length; i++) {
          final prev = (l.history[i - 1]['amount'] as num?)?.toDouble() ?? 0.0;
          final curr = (l.history[i]['amount'] as num?)?.toDouble() ?? 0.0;
          if (curr < prev) {
            repaid += (prev - curr);
          }
        }
        return sum + repaid;
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
            if (isCreditCard) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreditCardStatementsScreen(card: card),
                      ),
                    );
                  },
                  child: const Text('View Statements'),
                ),
              ),
              const SizedBox(height: 20),
            ],
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
            // const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(local.amountRepaid, style: Theme.of(context).textTheme.bodyMedium),
            //     Text('${Helpers.storeCurrency(context)}${totalRepaid.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            //   ],
            // ),
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
    final assetLiabilityVM = context.read<AssetLiabilityViewModel>();
    final accountCardVM = context.read<AccountCardViewModel>();
    // Use only bank assets as repayment sources
    final repaySources = assetLiabilityVM.assets.where((a) => a.type == 'Bank').toList();
    String? selectedSourceId;
    double selectedSourceBalance = 0.0;
    String? sourceErrorText;

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
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Bank Asset to Repay',
                    ),
                    value: selectedSourceId,
                    items: repaySources.map((asset) => DropdownMenuItem(
                      value: asset.id,
                      child: Text(
                        '${asset.name} (${Helpers.storeCurrency(context)}${asset.amount.toStringAsFixed(2)})',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedSourceId = value;
                        final src = repaySources.firstWhere((a) => a.id == value);
                        selectedSourceBalance = src.amount;
                        sourceErrorText = null;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a bank asset' : null,
                  ),
                  if (selectedSourceId != null) ...[
                    const SizedBox(height: 8),
                    Text('Available: ${Helpers.storeCurrency(context)}${selectedSourceBalance.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
                  ],
                  SizedBox(height: 12,),
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
                      if (sourceErrorText != null) {
                        setDialogState(() => sourceErrorText = null);
                      }
                  },
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                  if (sourceErrorText != null) ...[
                    const SizedBox(height: 8),
                    Text(sourceErrorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
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
                          if (selectedSourceId == null) {
                            setDialogState(() => sourceErrorText = 'Please select a bank asset to repay from.');
                            return;
                          }
                          final src = repaySources.firstWhere((a) => a.id == selectedSourceId);
                        if (entered <= 0) {
                          setDialogState(() => errorText = local.pleaseEnterAValidAmount);
                          return;
                        }
                        if (entered > maxAmount) {
                          setDialogState(() => errorText = local.amountExceedsRepay);
                          return;
                        }
                          if (entered > src.amount) {
                            setDialogState(() => sourceErrorText = 'Insufficient balance in the selected bank asset.');
                            return;
                          }
                        // Store the parent context before closing dialog
                        final parentContext = this.context;
                        Navigator.pop(dialogContext);
                        setState(() => _isRepayLoading = true);
                          // Deduct from selected bank asset
                          final updatedAsset = src.copyWith(amount: src.amount - entered);
                          await assetLiabilityVM.updateAssetLiability(updatedAsset);
                          // Deduct from linked debit card if any
                          final linkedCard = accountCardVM.accountCards.firstWhereOrNull(
                            (card) => card.linkedBankAssetId == src.id,
                          );
                          if (linkedCard != null) {
                            final updatedCard = linkedCard.copyWith(balance: linkedCard.balance - entered);
                            await accountCardVM.updateAccountCard(updatedCard);
                          }
                          // Repay the credit card liability
                        await _handleRepayment(parentContext, cardLiabilities, entered);

                          // Automatically record transfer in transactions page
                          try {
                            final transactionVM = parentContext.read<TransactionViewModel>();
                            final now = DateTime.now();
                            // Withdrawal from bank asset
                            final withdrawalTransaction = TransactionModel(
                              id: const Uuid().v4(),
                              userId: transactionVM.currentUserId ?? '',
                              amount: entered,
                              type: TransactionType.expense,
                              category: 'Transfer',
                              description: 'Credit card repayment to ${widget.card.name}',
                              date: now,
                              paymentMethod: src.name,
                              isRecurring: false,
                            );
                            // Deposit to credit card
                            final depositTransaction = TransactionModel(
                              id: const Uuid().v4(),
                              userId: transactionVM.currentUserId ?? '',
                              amount: entered,
                              type: TransactionType.income,
                              category: 'Transfer',
                              description: 'Credit card repayment from ${src.name}',
                              date: now,
                              paymentMethod: widget.card.name,
                              isRecurring: false,
                            );
                            await transactionVM.addTransaction(withdrawalTransaction);
                            await transactionVM.addTransaction(depositTransaction);
                          } catch (e) {
                            debugPrint('Failed to record repayment transfer transaction: $e');
                          }

                        if (mounted) setState(() => _isRepayLoading = false);
                        if (parentContext.mounted) {
                          ToastUtils.showSuccessToast(parentContext, 
                            title: local.success, 
                            description: local.repaymentSuccessful);
                        }
                          final accountCardVM2 = parentContext.read<AccountCardViewModel>();
                          final updatedCard = accountCardVM2.accountCards.firstWhere(
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
    final latestCard = accountCardVM.accountCards.firstWhere(
      (c) => c.id == widget.card.id,
      orElse: () => widget.card,
    );
    double remaining = repayAmount;
    for (final liability in cardLiabilities) {
      if (remaining <= 0) break;
      final pay = remaining > liability.amount ? liability.amount : remaining;
      final newAmount = liability.amount - pay;
      final updated = liability.recordHistory(newAmount >= 0 ? newAmount : 0);
      await assetLiabilityVM.updateAssetLiability(updated);
      if (updated.amount == 0) {
        await assetLiabilityVM.deleteAssetLiability(updated.id);
      }
      remaining -= pay;
    }
    final updatedCard = latestCard.copyWith(balance: latestCard.balance + repayAmount);
    await accountCardVM.updateAccountCard(updatedCard);
    if (mounted) setState(() {
      _card = updatedCard;
    });
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
    final assetLiabilityVM = context.read<AssetLiabilityViewModel>();
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
                // Delete all liabilities for this card
                final liabilitiesToDelete = assetLiabilityVM.liabilities.where(
                  (l) => l.type == 'Credit Card' && l.cardId == widget.card.id
                ).toList();
                for (final liability in liabilitiesToDelete) {
                  await assetLiabilityVM.deleteAssetLiability(liability.id);
                }
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
