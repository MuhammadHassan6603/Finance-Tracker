import 'package:finance_tracker/core/constants/categories_list.dart';
import 'package:finance_tracker/core/constants/theme_constants.dart';
import 'package:finance_tracker/core/constants/validator.dart';
import 'package:finance_tracker/core/services/local_notification_service.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/data/models/asset_liability_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/viewmodels/transaction_viewmodel.dart';
import 'package:finance_tracker/widgets/custom_button.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/console.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/motion_toast.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../widgets/custom_loader.dart';
import '../cards/add_card_sheet.dart';
import '../../../data/providers/budget_provider.dart';
import '../../../viewmodels/budget_viewmodel.dart';
import '../../../viewmodels/asset_liability_viewmodel.dart';

class AddTransactionSheet extends StatefulWidget {
  final bool isEditing;
  final TransactionModel? transaction;
  final Future<void> Function(TransactionModel)? onSave;

  const AddTransactionSheet({
    super.key,
    this.isEditing = false,
    this.transaction,
    this.onSave,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _splitNameController = TextEditingController();
  final _splitEmailController = TextEditingController();

  // Transaction State
  bool isIncome = false;
  bool isTransfer = false;
  String? selectedCategory;
  String? selectedPaymentMethod;
  DateTime selectedDate = DateTime.now();
  double? availableBudget;
  String? fromAccount;
  String? toAccount;

  // Recurring Transaction State
  bool isRecurring = false;
  String recurringFrequency = 'Monthly';

  // Split Transaction State
  bool isSplitTransaction = false;
  String splitType = 'Equal';
  List<Map<String, dynamic>> splitWith = [];

  // Custom Categories
  final List<Map<String, dynamic>> _customCategories = [];

  // Constants
  static const _availableIcons = [
    FontAwesome.tag_solid,
    FontAwesome.bag_shopping_solid,
    FontAwesome.burger_solid,
    FontAwesome.cart_shopping_solid,
    FontAwesome.house_solid,
    FontAwesome.car_solid,
    FontAwesome.heart_pulse_solid,
    FontAwesome.graduation_cap_solid,
    FontAwesome.plane_solid,
    FontAwesome.money_bill_solid,
    FontAwesome.gift_solid,
    FontAwesome.shirt_solid,
    FontAwesome.phone_solid,
    FontAwesome.futbol_solid,
    FontAwesome.palette_solid,
  ];

  static const _recurringFrequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _initializeDateTime();
    if (widget.isEditing && widget.transaction != null) {
      _initializeEditingMode();
    }
  }

  void _initializeDateTime() {
    _dateController.text = DateFormat('MMM d, yyyy').format(selectedDate);
    _timeController.text = DateFormat('hh:mm a').format(selectedDate);
  }

  void _initializeEditingMode() {
    final transaction = widget.transaction!;
    setState(() {
      isIncome = transaction.type == TransactionType.income;
      selectedCategory = transaction.category;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
      selectedDate = transaction.date;
      selectedPaymentMethod = transaction.paymentMethod;
      _initializeDateTime();
    });
    _updateAvailableBudget(selectedCategory);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _splitNameController.dispose();
    _splitEmailController.dispose();
    super.dispose();
  }

  // UI Building Methods
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Material(
      child: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.error == local.unauthorized) {
            return Center(
              child: Text(local.unauthorized),
            );
          }
          if (viewModel.isLoading) {
            return const Center(child: CustomLoadingOverlay());
          }

          return Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const Gap(24),
                    _buildTransactionTypeSelector(),
                    const Gap(16),
                    if (!isTransfer) ...[
                      _buildTransactionForm(),
                    ] else ...[
                      _buildTransferForm(),
                    ],
                    const Gap(24),
                    if (viewModel.error != null) ...[
                      Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const Gap(16),
                    ],
                    _buildSubmitButton(),
                    const Gap(16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final local = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isTransfer ? local.transferMoney : local.addTransaction,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Iconsax.tag_cross_bold),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSelector() {
    final local = AppLocalizations.of(context);
    return Row(
      children: [
        _buildTypeChip(
          label: local.expense,
          isSelected: !isIncome && !isTransfer,
          color: Colors.red[400]!,
          onSelected: (_) => setState(() {
            isIncome = false;
            isTransfer = false;
            selectedCategory = null;
          }),
        ),
        const Gap(8),
        _buildTypeChip(
          label: local.income,
          isSelected: isIncome && !isTransfer,
          color: ThemeConstants.primaryColor,
          onSelected: (_) => setState(() {
            isIncome = true;
            isTransfer = false;
            selectedCategory = null;
          }),
        ),
        const Gap(8),
        _buildTypeChip(
          label: local.transfer,
          isSelected: isTransfer,
          color: Theme.of(context).colorScheme.primary,
          onSelected: (_) => setState(() {
            isTransfer = true;
            selectedCategory = null;
          }),
        ),
      ],
    );
  }

  Widget _buildTypeChip({
    required String label,
    required bool isSelected,
    required Color color,
    required Function(bool) onSelected,
  }) {
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: color.withOpacity(0.8),
        backgroundColor: color.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide(color: isSelected ? Colors.white : color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTransactionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategorySelector(),
        const Gap(16),
        _buildAmountField(),
        const Gap(16),
        _buildDescriptionField(),
        const Gap(16),
        _buildDateTimePicker(),
        const Gap(16),
        _buildPaymentMethodField(),
        if (!isTransfer) ...[
          const Gap(16),
          _buildRecurringSection(),
          const Gap(16),
          _buildSplitSection(),
        ],
      ],
    );
  }

  Widget _buildTransferForm() {
    final accountViewModel = context.watch<AccountCardViewModel>();
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: local.fromAccount,
            prefixIcon: const Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: fromAccount,
          items: [
            ...accountViewModel.accountCards.map((card) => DropdownMenuItem(
                  value: card.id,
                  child: Row(
                    children: [
                      Icon(card.icon, color: card.color),
                      const SizedBox(width: 8),
                      Text(card.name),
                      const SizedBox(width: 8),
                      Text('(${card.balance.toStringAsFixed(2)})'),
                    ],
                  ),
                )),
          ],
          onChanged: (value) {
            if (value == toAccount) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Cannot select the same account for both fields'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            setState(() => fromAccount = value);
          },
          validator: (value) =>
              value == null ? 'Please select source account' : null,
        ),
        const Gap(16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: local.toAccount,
            prefixIcon: const Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: toAccount,
          items: [
            ...accountViewModel.accountCards.map((card) => DropdownMenuItem(
                  value: card.id,
                  child: Row(
                    children: [
                      Icon(card.icon, color: card.color),
                      const SizedBox(width: 8),
                      Text(card.name),
                      const SizedBox(width: 8),
                      Text('(${card.balance.toStringAsFixed(2)})'),
                    ],
                  ),
                )),
          ],
          onChanged: (value) {
            if (value == fromAccount) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Cannot select the same account for both fields'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            setState(() => toAccount = value);
          },
          validator: (value) =>
              value == null ? 'Please select destination account' : null,
        ),
        const Gap(16),
        CustomTextField(
          controller: _amountController,
          labelText: local.transferAmount,
          hintText: local.enterAmountToTransfer,
          icon: Iconsax.money_2_bold,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return local.pleaseEnterAnAmount;
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return local.pleaseEnterAValidAmount;
            }

            // Get the source account balance
            if (fromAccount != null) {
              final sourceAccount = accountViewModel.accountCards.firstWhere(
                (card) => card.id == fromAccount,
                orElse: () => throw Exception('Account not found'),
              );

              if (amount > sourceAccount.balance) {
                return local.insufficientBalance;
              }
            }

            return null;
          },
        ),
        const Gap(16),
        _buildDescriptionField(),
        const Gap(16),
        _buildDateTimePicker(),
      ],
    );
  }

  // Helper Methods for UI Components
  Widget _buildCategorySelector() {
    final local = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: selectedCategory),
          decoration: InputDecoration(
            labelText: local.categoryLabel,
            prefixIcon: Icon(_getSelectedIcon()),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Iconsax.arrow_down_1_bold),
          ),
          onTap: _showCategoryBottomSheet,
        ),
        if (availableBudget != null && !isIncome) ...[
          const Gap(4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '${local.availableBudget}: ${Helpers.storeCurrency(context)}${availableBudget!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: availableBudget! < 0
                        ? Colors.red
                        : Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.5),
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountField() {
    final local = AppLocalizations.of(context);
    final viewModel = context.read<TransactionViewModel>();
    final accountViewModel = context.watch<AccountCardViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _amountController,
          labelText: local.amount,
          hintText: local.enterAmount,
          icon: Iconsax.money_2_bold,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return local.pleaseEnterAnAmount;
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return local.pleaseEnterAValidAmount;
            }
            
            // Check if a payment method is selected and it's not cash wallet
            if (selectedPaymentMethod != null && selectedPaymentMethod != local.cashWallet) {
              final selectedCard = accountViewModel.accountCards.firstWhere(
                (card) => card.name == selectedPaymentMethod,
                orElse: () => throw Exception('Selected card not found'),
              );

              // For expenses, check if amount exceeds available balance
              if (!isIncome && amount > selectedCard.balance) {
                return 'Amount exceeds available balance (${Helpers.storeCurrency(context)}${selectedCard.balance.toStringAsFixed(2)})';
              }
            }

            return null;
          },
        ),
        if (!isIncome) ...[
          const Gap(4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              '${local.availableBalance}: ${Helpers.storeCurrency(context)}${availableBudget?.toStringAsFixed(2)}' ??
                  '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.5),
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionField() {
    final local = AppLocalizations.of(context);
    return CustomTextField(
      controller: _descriptionController,
      labelText: local.description,
      hintText: local.enterDescription,
      icon: Iconsax.note_1_bold,
      maxLines: 3,
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildDateField(),
        ),
        const Gap(5),
        Expanded(
          child: _buildTimeField(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final local = AppLocalizations.of(context);
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: local.date,
        prefixIcon: const Icon(Iconsax.calendar_1_bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            selectedDate = DateTime(
              date.year,
              date.month,
              date.day,
              selectedDate.hour,
              selectedDate.minute,
            );
            _dateController.text =
                DateFormat('MMM d, yyyy').format(selectedDate);
          });
        }
      },
    );
  }

  Widget _buildTimeField() {
    final local = AppLocalizations.of(context);
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: local.time,
        prefixIcon: const Icon(Iconsax.clock_bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDate),
        );
        if (time != null) {
          setState(() {
            selectedDate = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              time.hour,
              time.minute,
            );
            _timeController.text = DateFormat('hh:mm a').format(selectedDate);
          });
        }
      },
    );
  }

  Widget _buildPaymentMethodField() {
    final local = AppLocalizations.of(context);
    final accountViewModel = context.watch<AccountCardViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: local.paymentMethod,
            prefixIcon: const Icon(Icons.payment_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          value: selectedPaymentMethod ?? local.cashWallet,
          items: [
            DropdownMenuItem(
                value: local.cashWallet, child: Text(local.cashWallet)),
            ...accountViewModel.accountCards.map((card) =>
                DropdownMenuItem(value: card.name, child: Text(card.name))),
            DropdownMenuItem(
              value: 'add_new',
              child: Row(
                children: [
                  const Icon(Icons.add),
                  const Gap(8),
                  Text(local.addNewAccount),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value == 'add_new') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddCardSheet(),
              ).then((_) {
                // Reset to previous selection or Cash Wallet
                setState(() => selectedPaymentMethod =
                    selectedPaymentMethod ?? local.cashWallet);
              });
            } else {
              setState(() => selectedPaymentMethod = value);
            }
          },
          validator: (value) =>
              value == null ? local.pleaseSelectAPaymentMethod : null,
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          title: Text(local.recurringTransaction),
          value: isRecurring,
          onChanged: (value) => setState(() => isRecurring = value),
        ),
        if (isRecurring) ...[
          const Gap(8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: local.frequency,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            value: recurringFrequency,
            items: _recurringFrequencies
                .map((freq) => DropdownMenuItem(
                      value: freq,
                      child: Text(freq),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => recurringFrequency = value!);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSplitSection() {
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          title: Text(local.splitTransaction),
          value: isSplitTransaction,
          onChanged: (value) => setState(() => isSplitTransaction = value),
        ),
        if (isSplitTransaction) ...[
          const Gap(8),
          _buildSplitTypeSelector(),
          const Gap(8),
          _buildSplitMembersList(),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    final local = AppLocalizations.of(context);
    return CustomButton(
      onPressed: _handleSubmit,
      child: Text(
        widget.isEditing
            ? local.updateTransaction
            : (isTransfer ? local.transferMoney : local.saveTransaction),
      ),
    );
  }

  // Action Methods
  void _handleSubmit() async {
    final local = AppLocalizations.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<TransactionViewModel>();
      final accountViewModel = context.read<AccountCardViewModel>();
      final assetViewModel = context.read<AssetLiabilityViewModel>();

      try {
        if (isTransfer) {
          // Handle transfer between accounts
          final sourceAccount = accountViewModel.accountCards.firstWhere(
            (card) => card.id == fromAccount,
            orElse: () => throw Exception('Source account not found'),
          );

          final destinationAccount = accountViewModel.accountCards.firstWhere(
            (card) => card.id == toAccount,
            orElse: () => throw Exception('Destination account not found'),
          );

          final amount = double.tryParse(_amountController.text) ?? 0.0;

          // Create withdrawal transaction for source account
          final withdrawalTransaction = TransactionModel(
            id: const Uuid().v4(),
            userId: viewModel.currentUserId ?? '',
            amount: amount,
            type: TransactionType.expense,
            category: local.transfer,
            description: 'Transfer to ${destinationAccount.name}',
            date: selectedDate,
            paymentMethod: sourceAccount.name,
            isRecurring: false,
          );

          // Create deposit transaction for destination account
          final depositTransaction = TransactionModel(
            id: const Uuid().v4(),
            userId: viewModel.currentUserId ?? '',
            amount: amount,
            type: TransactionType.income,
            category: local.transfer,
            description: 'Transfer from ${sourceAccount.name}',
            date: selectedDate,
            paymentMethod: destinationAccount.name,
            isRecurring: false,
          );

          // Update account balances
          await accountViewModel.updateAccountCard(
            sourceAccount.copyWith(balance: sourceAccount.balance - amount),
          );

          await accountViewModel.updateAccountCard(
            destinationAccount.copyWith(balance: destinationAccount.balance + amount),
          );

          // If source account is linked to a bank asset, update its amount
          if (sourceAccount.linkedBankAssetId != null) {
            final bankAsset = assetViewModel.assets.firstWhere(
              (asset) => asset.id == sourceAccount.linkedBankAssetId,
              orElse: () => throw Exception('Linked bank asset not found'),
            );
            await assetViewModel.updateAssetLiability(
              bankAsset.copyWith(amount: bankAsset.amount - amount),
            );
          }

          // If destination account is linked to a bank asset, update its amount
          if (destinationAccount.linkedBankAssetId != null) {
            final bankAsset = assetViewModel.assets.firstWhere(
              (asset) => asset.id == destinationAccount.linkedBankAssetId,
              orElse: () => throw Exception('Linked bank asset not found'),
            );
            await assetViewModel.updateAssetLiability(
              bankAsset.copyWith(amount: bankAsset.amount + amount),
            );
          }

          // Save both transactions
          await viewModel.addTransaction(withdrawalTransaction);
          await viewModel.addTransaction(depositTransaction);

          if (mounted) {
            Navigator.pop(context);
            ToastUtils.showSuccessToast(
              context,
              title: local.success,
              description: local.transferCompletedSuccessfully,
            );
          }
        } else {
          // Handle regular transaction
          final amount = double.tryParse(_amountController.text) ?? 0.0;
          
          // Update card balance if a card is selected
          if (selectedPaymentMethod != null && selectedPaymentMethod != local.cashWallet) {
            final selectedCard = accountViewModel.accountCards.firstWhere(
              (card) => card.name == selectedPaymentMethod,
              orElse: () => throw Exception('Selected card not found'),
            );

            // Update card balance based on transaction type
            final newBalance = isIncome 
                ? selectedCard.balance + amount 
                : selectedCard.balance - amount;

            await accountViewModel.updateAccountCard(
              selectedCard.copyWith(balance: newBalance),
            );

            // Only try to update bank asset if the card is linked to one
            if (selectedCard.linkedBankAssetId != null) {
              try {
                final bankAsset = assetViewModel.assets.firstWhere(
                  (asset) => asset.id == selectedCard.linkedBankAssetId,
                  orElse: () => throw Exception('Linked bank asset not found'),
                );
                
                // Update bank asset amount based on transaction type
                final newAssetAmount = isIncome
                    ? bankAsset.amount + amount
                    : bankAsset.amount - amount;

                await assetViewModel.updateAssetLiability(
                  bankAsset.copyWith(amount: newAssetAmount),
                );
              } catch (e) {
                // If bank asset is not found, just log it and continue
                debugPrint('Bank asset not found for card ${selectedCard.name}: $e');
              }
            }

            // If it's a credit card expense, add it to liabilities
            if (!isIncome && selectedCard.type == 'Credit Card') {
              // Create a new liability for the credit card expense
              final liability = AssetLiabilityModel(
                id: const Uuid().v4(),
                userId: viewModel.currentUserId ?? '',
                isAsset: false,
                type: 'Credit Card',
                amount: amount,
                name: _descriptionController.text,
                startDate: selectedDate,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isActive: true,
                cardId: selectedCard.id,
              );

              await assetViewModel.createAssetLiability(liability);
            }
          }

          final transaction = TransactionModel(
            id: widget.isEditing ? widget.transaction!.id : const Uuid().v4(),
            userId: viewModel.currentUserId ?? '',
            amount: amount,
            type: isIncome ? TransactionType.income : TransactionType.expense,
            category: selectedCategory ?? 'Uncategorized',
            description: _descriptionController.text,
            date: selectedDate,
            paymentMethod: selectedPaymentMethod ?? local.cashWallet,
            isRecurring: isRecurring,
            recurringFrequency: isRecurring ? recurringFrequency : null,
            splitWith: isSplitTransaction ? splitWith : null,
          );

          console('Transaction: ${transaction.description}', type: DebugType.response);
          bool success;
          if (widget.isEditing) {
            success = await viewModel.updateTransaction(transaction);
          } else {
            success = await viewModel.addTransaction(transaction);
          }

          if (success && !isIncome && selectedCategory != null) {
            await Provider.of<BudgetProvider>(context, listen: false)
                .addSpendingToCategory(selectedCategory!, amount);
          }

          if (isRecurring) {
            await _scheduleRecurringNotification(transaction);
          }

          if (success && mounted) {
            Navigator.pop(context);
            ToastUtils.showSuccessToast(
              context,
              title: local.success,
              description: widget.isEditing
                  ? local.transactionUpdatedSuccessfully
                  : local.transactionAddedSuccessfully,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          console('$e', type: DebugType.error);
          ToastUtils.showErrorToast(
            context,
            title: local.operationFailed,
            description: 'Error: ${e.toString()}',
          );
        }
      }
    }
  }

  dynamic _getSelectedIcon() {
    if (selectedCategory == null) return Icons.category;

    final categoryData = CategoryList.categories.firstWhere(
      (cat) => cat['title'] == selectedCategory,
      orElse: () => _customCategories.firstWhere(
        (cat) => cat['title'] == selectedCategory,
        orElse: () => {'icon': Icons.category},
      ),
    );

    return categoryData['icon'];
  }

  void _showCategoryBottomSheet() {
    final local = AppLocalizations.of(context);
    final baseCategories = isIncome
        ? CategoryList.categories.sublist(0, 9)
        : CategoryList.categories.sublist(9);

    final allCategories = [...baseCategories, ..._customCategories];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  local.selectCategory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddCategoryDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(local.newCategory),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final category = allCategories[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['title'];
                        _updateAvailableBudget(category['title']);
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedCategory == category['title']
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Gap(8),
                          Text(
                            category['title'],
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final local = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    String categoryName = '';
    IconData selectedIcon = FontAwesome.tag_solid; // Default icon

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(local.addNewCategory),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                labelText: local.categoryName,
                validator: (value) =>
                    value?.isEmpty ?? true ? local.pleaseEnterAName : null,
                onChanged: (value) => categoryName = value,
              ),
              const Gap(16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    return IconButton(
                      onPressed: () {
                        selectedIcon = icon;
                        (context as Element).markNeedsBuild();
                      },
                      icon: Icon(
                        icon,
                        color: selectedIcon == icon
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                // Add the new category to custom categories
                final newCategory = {
                  "title": categoryName,
                  "icon": selectedIcon,
                };

                setState(() {
                  _customCategories.add(newCategory);
                });

                Navigator.pop(context);
                _showCategoryBottomSheet(); // Reopen category selector
              }
            },
            child: Text(local.add),
          ),
        ],
      ),
    );
  }

  void _updateAvailableBudget(String? category) {
    if (category == null) {
      setState(() {
        availableBudget = null;
      });
      return;
    }

    final budgetVM = context.read<BudgetViewModel>();
    setState(() {
      availableBudget = budgetVM.getAvailableBudgetForCategory(category);
    });
  }

  void _showAddSplitMemberDialog() {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(local.addPersonToSplit),
        content: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _splitNameController,
              labelText: local.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return local.pleaseEnterAName;
                }
                return null;
              },
            ),
            CustomTextField(
              controller: _splitEmailController,
              labelText: local.email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return local.pleaseEnterTheEmail;
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                splitWith.add({
                  'name': _splitNameController.text,
                  'email': _splitEmailController.text,
                  'percentage':
                      splitType == 'Equal' ? 100 / (splitWith.length + 2) : 0,
                });
              });
              Navigator.pop(context);
            },
            child: Text(local.add),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTypeSelector() {
    final local = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: Text(local.splitEqually),
            selected: splitType == 'Equal',
            onSelected: (selected) => setState(() => splitType = 'Equal'),
          ),
        ),
        const Gap(8),
        Expanded(
          child: ChoiceChip(
            label: Text(local.customSplit),
            selected: splitType == 'Custom',
            onSelected: (selected) => setState(() => splitType = 'Custom'),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitMembersList() {
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _showAddSplitMemberDialog,
          icon: const Icon(Icons.person_add),
          label: Text(local.addPersonToSplit),
        ),
        if (splitWith.isNotEmpty) ...[
          const Gap(8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: splitWith.length,
            itemBuilder: (context, index) {
              final person = splitWith[index];
              return ListTile(
                title: Text(person['name']),
                subtitle: Text(person['email']),
                trailing: splitType == 'Custom'
                    ? SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: const InputDecoration(suffix: Text('%')),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => splitWith[index]
                              ['percentage'] = double.tryParse(value) ?? 0),
                        ),
                      )
                    : Text('${100 / (splitWith.length + 1)}%'),
                leading: const CircleAvatar(child: Icon(Icons.person)),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _scheduleRecurringNotification(
      TransactionModel transaction) async {
    final notificationService = ScheduledNotificationService();
    final nextOccurrence =
        _calculateNextOccurrence(selectedDate, recurringFrequency);

    // Schedule notification 1 day before the next occurrence
    final notificationDate = nextOccurrence.subtract(const Duration(days: 1));

    await notificationService.scheduleBillReminder(
      id: transaction.hashCode,
      title: 'Recurring Transaction Reminder',
      body:
          'Your recurring ${transaction.type == TransactionType.income ? 'income' : 'expense'} of ${Helpers.storeCurrency(context)}${transaction.amount} for ${transaction.category} is due tomorrow',
      scheduledDate: notificationDate,
      billId: transaction.id,
    );
  }

  DateTime _calculateNextOccurrence(DateTime currentDate, String frequency) {
    switch (frequency) {
      case 'Daily':
        return currentDate.add(const Duration(days: 1));
      case 'Weekly':
        return currentDate.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(
            currentDate.year, currentDate.month + 1, currentDate.day);
      case 'Yearly':
        return DateTime(
            currentDate.year + 1, currentDate.month, currentDate.day);
      default:
        return currentDate;
    }
  }
}
