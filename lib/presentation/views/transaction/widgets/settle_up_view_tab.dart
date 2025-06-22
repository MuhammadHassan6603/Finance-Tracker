import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/data/models/settlement_model.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/viewmodels/settlement_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/motion_toast.dart';
import '../../../../widgets/custom_loader.dart';
import '../../../../widgets/custom_text_field.dart';

class SettleUpViewTab extends StatefulWidget {
  const SettleUpViewTab({super.key});

  @override
  State<StatefulWidget> createState() => _SettleUpViewTabState();
}

class _SettleUpViewTabState extends State<SettleUpViewTab> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final viewModel = context.read<SettlementViewModel>();
    if (_isInitialLoad && !viewModel.isLoading) {
      await viewModel.reLoadSettlement();
      _isInitialLoad = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = context.watch<SettlementViewModel>();

    // Only show error if it's new
    if (viewModel.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ToastUtils.showErrorToast(
          context,
          title: 'Operation Failed',
          description: viewModel.error!,
        );
        viewModel.clearError();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettlementViewModel>();
    final local = AppLocalizations.of(context);
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showAddSettlementDialog(context),
                icon: const Icon(Icons.add),
                label: Text(local.addNewSettlement),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ),
            if (viewModel.combinedSettlementData.isEmpty &&
                !viewModel.isLoading)
              Expanded(
                child: Center(child: Text(local.noSettlementsFound)),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.combinedSettlementData.length,
                  itemBuilder: (context, index) {
                    final personName =
                        viewModel.combinedSettlementData.keys.elementAt(index);
                    final data = viewModel.combinedSettlementData[personName]!;
                    print(data);
                    return _buildDismissibleSettlementCard(
                      personName,
                      data['totalAmount'] as double,
                      data['isOwed'] as bool,
                      data['settlements'] as List<SettlementModel>,
                      data['splitTransactions'] as List<TransactionModel>,
                      context,
                    );
                  },
                ),
              ),
          ],
        ),
        if (viewModel.isLoading) const CustomLoadingOverlay(),
      ],
    );
  }

  Widget _buildDismissibleSettlementCard(
      String personName,
      double totalAmount,
      bool isOwed,
      List<SettlementModel> settlements,
      List<TransactionModel> splitTransactions,
      BuildContext context) {
    final local = AppLocalizations.of(context);
    return Dismissible(
      key: Key(personName),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(local.deleteSettlement),
              content: Text(local.confirmDeleteSettlement),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(local.cancelButton),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(local.delete),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        final viewModel = context.read<SettlementViewModel>();
        for (var settlement in settlements) {
          viewModel.deleteSettlement(settlement.id);
        }
        ToastUtils.showSuccessToast(context,
            title: local.deleted,
            description: local.settlementDeletedSuccessfully);
      },
      child: _buildSettlementCard(personName, totalAmount, isOwed, context),
    );
  }

  Widget _buildSettlementCard(String personName, double totalAmount,
      bool isOwed, BuildContext context) {
    final viewModel = context.read<SettlementViewModel>();
    final local = AppLocalizations.of(context);
    final data = viewModel.combinedSettlementData[personName]!;
    final splitAmount = data['splitAmount'] as double;
    final settlements = data['settlements'] as List<SettlementModel>;
    final splitTransactions = data['splitTransactions'] as List<TransactionModel>;

    // Determine the amount and relationship to display
    // If total amount is 0 and there are split transactions, it's purely from splits
    final isPurelySplit = totalAmount == 0 && splitTransactions.isNotEmpty && settlements.isEmpty;

    final displayAmount = totalAmount == 0 ? splitAmount : totalAmount;
    // If purely split, they owe you. Otherwise, use the isOwed flag from combined data (which considers manual settlements)
    final displayIsOwed = isPurelySplit ? false : isOwed; 

    // Determine the subtitle text
    String subtitleText;
    if (isPurelySplit) {
      // Indicate that this is from split transactions
      subtitleText = '${local.owesYou} from splits'; // Assuming you have a localization key for 'fromSplits'
    } else {
      // Use the standard "You owe" or "Owes you" text based on combined data
      subtitleText = displayIsOwed ? local.youOwe : local.owesYou;
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(personName.isNotEmpty ? personName[0] : '?'),
        ),
        title: Text(personName),
        subtitle: Text(
          subtitleText, // Use the determined subtitle text
          style: TextStyle(
            color: displayIsOwed ? Colors.red : Colors.green,
          ),
        ),
        trailing: Text(
          '${Helpers.storeCurrency(context)}${displayAmount.toStringAsFixed(2)}',
          style: TextStyle(
            color: displayIsOwed ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () =>
            _showSettlementDetails(personName, totalAmount, isOwed, context),
      ),
    );
  }

  void _showAddSettlementDialog(BuildContext context) {
    final viewModel = context.read<SettlementViewModel>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    bool isYouOwe = false;
    final local = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      local.addNewSettlement,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Gap(24),
                CustomTextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    labelText: local.personName,
                    icon: Icons.person_outline),
                const Gap(16),
                CustomTextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  labelText: local.amountLabel,
                  icon: Icons.currency_rupee,
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: _buildChip(
                        label: local.theyOweMe,
                        isSelected: !isYouOwe,
                        onSelected: (selected) {
                          setState(() => isYouOwe = !selected);
                        },
                        selectedColor: Colors.green.withOpacity(0.2),
                        labelColor: !isYouOwe ? Colors.green : null,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _buildChip(
                        label: local.iOweThem,
                        isSelected: isYouOwe,
                        onSelected: (selected) {
                          setState(() => isYouOwe = selected);
                        },
                        selectedColor: Colors.red.withOpacity(0.2),
                        labelColor: isYouOwe ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ToastUtils.showErrorToast(
                        context,
                        title: local.invalidInput,
                        description: local.pleaseEnterAName,
                      );
                      return;
                    }

                    final amountText =
                        amountController.text.replaceAll(',', '.');
                    final amount = double.tryParse(amountText);

                    if (amount == null || amount <= 0) {
                      ToastUtils.showErrorToast(
                        context,
                        title: local.invalidAmount,
                        description: local.pleaseEnterAValidNumber,
                      );
                      return;
                    }

                    final success = await viewModel.addSettlement(
                      title: nameController.text,
                      amount: amount,
                      isOwed: isYouOwe,
                      participants: [],
                    );

                    if (success && context.mounted) {
                      ToastUtils.showSuccessToast(
                        context,
                        title: local.success,
                        description: local.settlementAddedSuccessfully,
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(local.addSettlement),
                ),
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettlementDetails(String personName, double totalAmount,
      bool isOwed, BuildContext context) {
    final viewModel = context.read<SettlementViewModel>();
    final local = AppLocalizations.of(context);
    final data = viewModel.combinedSettlementData[personName]!;
    final settlements = data['settlements'] as List<SettlementModel>;
    final splitTransactions =
        data['splitTransactions'] as List<TransactionModel>;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOwed
                  ? '${local.youOwe} $personName'
                  : '$personName ${local.owesYou}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(16),
            Text(
              '${Helpers.storeCurrency(context)}${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isOwed ? Colors.red : Colors.green,
                  ),
            ),
            const Gap(24),
            if (settlements.isNotEmpty) ...[
              Text(
                'Related Settlements:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              ...settlements.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                        '${s.title}: ${Helpers.storeCurrency(context)}${s.amount.toStringAsFixed(2)}'),
                  )),
            ],
            if (splitTransactions.isNotEmpty) ...[
              const Gap(16),
              Text(
                '${local.relatedTransactions}:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              ...splitTransactions.map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                        '${t.category}: ${Helpers.storeCurrency(context)}${t.amount.toStringAsFixed(2)}'),
                  )),
            ],
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (settlements.isNotEmpty) {
                    // Mark all settlements as paid
                    for (var settlement in settlements) {
                      await viewModel.markAsPaid(settlement.id);
                    }
                  } else if (splitTransactions.isNotEmpty) {
                    // Create a new settlement from split transactions
                    await viewModel.createSettlementFromSplit(personName);
                  }

                  if (context.mounted) {
                    ToastUtils.showSuccessToast(
                      context,
                      title: local.success,
                      description: isOwed
                          ? local.paymentMarkedAsCompleted
                          : local.reminderSentSuccessfully,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  isOwed ? local.payNow : local.remind,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    Color selectedColor = Colors.green,
    Color? labelColor,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: selectedColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? labelColor : null,
      ),
    );
  }
}
