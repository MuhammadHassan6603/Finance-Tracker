import 'package:finance_tracker/core/constants/console.dart';
import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/widgets/custom_loader.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../generated/l10n.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../data/models/account_card_model.dart';
import '../../../core/utils/motion_toast.dart';
import '../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../data/models/asset_liability_model.dart';
import 'dart:math' as num;

class AddCardSheet extends StatefulWidget {
  final AccountCardModel? card;
  final bool isEditing;

  const AddCardSheet({
    super.key,
    this.card,
    this.isEditing = false,
  });

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _unpaidAmountController = TextEditingController();

  late String _cardType;
  late Color _cardColor;
  late IconData _cardIcon;
  bool _isProcessing = false;
  String? _linkedBankAssetId;
  bool _isBalanceLocked = false;
  DateTime? _firstStatementDate; // for credit card statement
  int? _statementDayOfMonth;

  @override
  void initState() {
    super.initState();
    _cardType = widget.card?.type ?? 'Credit Card';
    _nameController.text = widget.card?.name ?? '';
    _accountNameController.text = widget.card?.accountName ?? '';
    _numberController.text = widget.card?.number ?? '';
    _balanceController.text = (widget.card?.balance ?? 0.0).toString();
    _cardColor = widget.card?.color ?? Colors.blue;
    _cardIcon = widget.card?.icon ?? Icons.account_balance;
    if (widget.isEditing && widget.card != null && widget.card!.type == 'Credit Card') {
      _firstStatementDate = widget.card!.firstStatementDate;
      _statementDayOfMonth = widget.card!.statementDayOfMonth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountNameController.dispose();
    _numberController.dispose();
    _balanceController.dispose();
    _unpaidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);
    final assetVM = context.watch<AssetLiabilityViewModel>();
    final accountVM = context.watch<AccountCardViewModel>();
    
    // Get all bank assets
    final allBankAssets = assetVM.assets
        .where((asset) => asset.type == 'Bank')
        .toList();

    // Get IDs of bank assets that are already linked to other cards
    final linkedBankAssetIds = accountVM.accountCards
        .where((card) => card.linkedBankAssetId != null)
        .map((card) => card.linkedBankAssetId!)
        .toSet();

    // Filter out bank assets that are already linked to other cards
    // If we're editing, include the currently linked bank asset
    final availableBankAssets = allBankAssets.where((asset) {
      if (widget.isEditing && widget.card?.linkedBankAssetId == asset.id) {
        return true; // Include the currently linked asset when editing
      }
      return !linkedBankAssetIds.contains(asset.id); // Exclude already linked assets
    }).toList();

    // If the currently selected bank asset is not in the available list, reset it
    if (_linkedBankAssetId != null && 
        !availableBankAssets.any((asset) => asset.id == _linkedBankAssetId)) {
      _linkedBankAssetId = null;
    }

    return Material(
      color: isDarkMode ? ThemeConstants.surfaceDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.isEditing
                      ? localization.editCardAccount
                      : localization.addNewCardAccount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? ThemeConstants.textPrimaryDark
                            : ThemeConstants.textPrimaryLight,
                      ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _cardType,
                  decoration: InputDecoration(
                    labelText: localization.typeLabel,
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color: isDarkMode
                          ? ThemeConstants.textSecondaryDark
                          : ThemeConstants.textSecondaryLight,
                    ),
                  ),
                  items: ['Credit Card', 'Debit Card', 'E-Wallet']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _cardType = value!);
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  labelText: localization.personName,
                  validator: (value) => value?.isEmpty ?? true
                      ? localization.pleaseEnterAName
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _accountNameController,
                  labelText: localization.accountName,
                  validator: (value) => value?.isEmpty ?? true
                      ? localization.pleaseEnterAName
                      : null,
                ),
                const Gap(16),
                CustomTextField(
                  controller: _numberController,
                  labelText: localization.cardAccountNumber,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true
                      ? localization.pleaseEnterAValidNumber
                      : null,
                ),
                const SizedBox(height: 16),
                if (_cardType == 'Debit Card' || _cardType == 'E-Wallet')
                  _buildBankAssetDropdown(),
                if (_cardType == 'Debit Card' || _cardType == 'E-Wallet')
                  SizedBox(height: 16,),
                _buildBalanceField(),
                const SizedBox(height: 16),
                if (_cardType == 'Credit Card')
                  CustomTextField(
                    controller: _unpaidAmountController,
                    labelText: 'Unpaid Amount (optional)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final n = double.tryParse(value);
                        if (n == null || n < 0) {
                          return 'Please enter a valid number';
                        }
                        // Check if unpaid amount exceeds the card limit
                        final cardLimit = double.tryParse(_balanceController.text) ?? 0.0;
                        if (n > cardLimit) {
                          return 'Unpaid amount cannot exceed card limit';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Trigger rebuild to update the helper text
                      setState(() {});
                    },
                  ),
                if (_cardType == 'Credit Card' && _unpaidAmountController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Available balance after deduction: ${_calculateAvailableBalance()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                if (_cardType == 'Credit Card' && !widget.isEditing) ...[
                  const SizedBox(height: 16),
                  _buildStatementDatePicker(context),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Select the first statement generation date (within 45 days from today). All transactions before this date will be included in the first statement. This date cannot be changed later.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                _buildColorSelector(),
                const SizedBox(height: 16),
                _buildIconSelector(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(widget.isEditing
                        ? localization.updateCard
                        : localization.addCard),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final local = AppLocalizations.of(context);
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(local.cardColor),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _cardColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _cardColor == color ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    final icons = [
      Icons.account_balance,
      Icons.credit_card,
      Icons.account_balance_wallet,
      Icons.savings,
      Icons.payment,
      Icons.monetization_on,
      Icons.money,
      Icons.business,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Card Icon'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _cardIcon = icon;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _cardIcon == icon
                      ? _cardColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _cardIcon == icon ? _cardColor : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBankAssetDropdown() {
    final assetVM = context.watch<AssetLiabilityViewModel>();
    final accountVM = context.watch<AccountCardViewModel>();
    
    // Get all bank assets
    final allBankAssets = assetVM.assets
        .where((asset) => asset.type == 'Bank')
        .toList();

    // Get IDs of bank assets that are already linked to other cards
    final linkedBankAssetIds = accountVM.accountCards
        .where((card) => card.linkedBankAssetId != null)
        .map((card) => card.linkedBankAssetId!)
        .toSet();

    // Filter out bank assets that are already linked to other cards
    // If we're editing, include the currently linked bank asset
    final availableBankAssets = allBankAssets.where((asset) {
      if (widget.isEditing && widget.card?.linkedBankAssetId == asset.id) {
        return true; // Include the currently linked asset when editing
      }
      return !linkedBankAssetIds.contains(asset.id); // Exclude already linked assets
    }).toList();

    // If the currently selected bank asset is not in the available list, reset it
    if (_linkedBankAssetId != null && 
        !availableBankAssets.any((asset) => asset.id == _linkedBankAssetId)) {
      _linkedBankAssetId = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Link to Bank Asset'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _linkedBankAssetId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select a bank asset',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None'),
            ),
            ...availableBankAssets.map((asset) => DropdownMenuItem<String>(
                  value: asset.id,
                  child: Text(asset.name),
                )),
          ],
          onChanged: (value) {
            setState(() {
              _linkedBankAssetId = value;
              if (value != null) {
                final selectedAsset = allBankAssets.firstWhere(
                  (asset) => asset.id == value,
                  orElse: () => throw Exception('Selected asset not found'),
                );
                _balanceController.text = selectedAsset.amount.toString();
                _isBalanceLocked = true;
              } else {
                _isBalanceLocked = false;
                _balanceController.text = '';
              }
            });
          },
        ),
      ],
    );
  }

  String _calculateAvailableBalance() {
    final cardLimit = double.tryParse(_balanceController.text) ?? 0.0;
    final unpaidAmount = double.tryParse(_unpaidAmountController.text) ?? 0.0;
    final availableBalance = cardLimit - unpaidAmount;
    return availableBalance.toStringAsFixed(2);
  }

  Widget _buildBalanceField() {
    final local = AppLocalizations.of(context);
    return CustomTextField(
      controller: _balanceController,
      labelText: _cardType == 'Credit Card' ? 'Card Limit' : 'Balance',
      hintText: _cardType == 'Credit Card' ? 'Enter card limit' : 'Enter balance',
      icon: Icons.credit_card,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _cardType == 'Credit Card' ? 'Please enter card limit' : 'Please enter balance';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return _cardType == 'Credit Card' ? 'Please enter a valid card limit' : 'Please enter a valid balance';
        }
        return null;
      },
      onChanged: (value) {
        // Trigger rebuild to update the helper text for unpaid amount
        setState(() {});
      },
      readOnly: _linkedBankAssetId != null,
    );
  }

  Widget _buildStatementDatePicker(BuildContext context) {
    final local = AppLocalizations.of(context);
    final now = DateTime.now();
    final minDate = now.add(const Duration(days: 1));
    final maxDate = now.add(const Duration(days: 45));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('First Statement Generation Date', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _firstStatementDate ?? minDate,
              firstDate: minDate,
              lastDate: maxDate,
            );
            if (picked != null) {
              setState(() {
                _firstStatementDate = picked;
                _statementDayOfMonth = picked.day;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_firstStatementDate == null
                    ? 'Select date'
                    : '${_firstStatementDate!.day}/${_firstStatementDate!.month}/${_firstStatementDate!.year}'),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveCard() async {
    final local = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) {
      console('DEBUG: Form validation failed');
      return;
    }
    if (_cardType == 'Credit Card' && !widget.isEditing && _firstStatementDate == null) {
      ToastUtils.showErrorToast(context, title: 'Error', description: 'Please select a first statement generation date.');
      return;
    }

    if (!mounted) return;

    final viewModel = context.read<AccountCardViewModel>();
    if (viewModel.isLoading) {
      const CustomLoadingOverlay();
      console('DEBUG: ViewModel is already loading, skipping save operation');
      return;
    }

    console('DEBUG: Starting card save operation');
    console('DEBUG: Card type: $_cardType');
    console('DEBUG: Card name: $_nameController.text');
    console('DEBUG: Card number: $_numberController.text');
    console('DEBUG: Card balance: $_balanceController.text');

    try {
      bool success = false;

      if (widget.isEditing && widget.card != null) {
        final updatedCard = widget.card!.copyWith(
          accountName: _accountNameController.text,
          name: _nameController.text,
          number: _numberController.text,
          type: _cardType,
          balance: double.parse(_balanceController.text),
          color: _cardColor,
          icon: _cardIcon,
          linkedBankAssetId: _linkedBankAssetId,
          firstStatementDate: _firstStatementDate,
          statementDayOfMonth: _statementDayOfMonth,
        );
        
        success = await viewModel.updateAccountCard(updatedCard);
      } else {
        // Calculate the final balance for credit cards
        double finalBalance = double.parse(_balanceController.text);
        
        // If it's a credit card and unpaid amount is provided, deduct it from the balance
        if (_cardType == 'Credit Card' && _unpaidAmountController.text.isNotEmpty) {
          final unpaidAmount = double.tryParse(_unpaidAmountController.text) ?? 0.0;
          if (unpaidAmount > 0) {
            finalBalance -= unpaidAmount;
          }
        }
        
        // Create a new card with the linkedBankAssetId and statement fields
        success = await viewModel.createAccountCard(
          accountName: _accountNameController.text,
          name: _nameController.text,
          number: _numberController.text,
          type: _cardType,
          balance: finalBalance,
          color: _cardColor,
          icon: _cardIcon,
          linkedBankAssetId: _linkedBankAssetId,
          firstStatementDate: _firstStatementDate,
          statementDayOfMonth: _statementDayOfMonth,
        );
        
        // If unpaid amount is set, create a liability
        if (success && _cardType == 'Credit Card' && _unpaidAmountController.text.isNotEmpty) {
          final unpaidAmount = double.tryParse(_unpaidAmountController.text) ?? 0.0;
          if (unpaidAmount > 0) {
            final assetLiabilityVM = context.read<AssetLiabilityViewModel>();
            final newCard = viewModel.accountCards.firstWhere((c) =>
              c.name == _nameController.text &&
              c.number == _numberController.text &&
              c.type == 'Credit Card');
            final now = DateTime.now();
            final dueDate = now.add(const Duration(days: 30));
            await assetLiabilityVM.createAssetLiability(
              AssetLiabilityModel(
                id: UniqueKey().toString(),
                userId: viewModel.currentUserId ?? '',
                isAsset: false,
                type: 'Credit Card',
                amount: unpaidAmount,
                name: newCard.name,
                startDate: now,
                interestRate: 0.0,
                paymentSchedule: 'One-time',
                attachments: [],
                trackingPreferences: [],
                createdAt: now,
                updatedAt: now,
                isActive: true,
                history: [
                  {'amount': unpaidAmount, 'timestamp': now},
                ],
                description: 'Unpaid amount on card creation',
                cardId: newCard.id,
              ),
            );
          }
        }
      }

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(
            context,
            title: local.success,
            description: widget.isEditing
                ? local.cardUpdatedSuccessfully
                : local.cardAddedSuccessfully,
          );
        }
      }
    } catch (e) {
      console('DEBUG: Error saving card: $e', type: DebugType.error);
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          title: local.error,
          description: e.toString(),
        );
      }
    }
  }
}
