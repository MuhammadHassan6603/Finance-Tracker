import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/presentation/views/budget/widgets/budget_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/budget_model.dart';
import '../../../../generated/l10n.dart';
import '../../../../viewmodels/budget_viewmodel.dart';
import '../../../../viewmodels/transaction_viewmodel.dart';
import '../add_budget_sheet.dart';

class BudgetCategorySection extends StatelessWidget {
  final String title;

  const BudgetCategorySection({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Consumer2<BudgetViewModel, TransactionViewModel>(
      builder: (context, budgetVM, transactionVM, _) {
        final selectedMonth = budgetVM.selectedMonth;
        if (budgetVM.filteredBudgets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                local.noBudgetsAvailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgetVM.filteredBudgets.length,
              itemBuilder: (context, index) {
                final budget = budgetVM.filteredBudgets[index];

                final spent = budgetVM.getSpentForBudget(budget);
                final remaining = budget.amount - spent;

                return BudgetItem(
                  name: budget.category,
                  limit: budget.amount,
                  spent: spent,
                  remaining: remaining,
                  isShared: budget.collaborators.isNotEmpty,
                  collaborators: budget.collaborators,
                  onEdit: () => _showEditBudgetDialog(budget, context),
                  onShare: () {},
                  onDelete: () => _deleteBudget(budget.id, context),
                  icon: IconData(
                    int.parse(budget.icon),
                    fontFamily: budget.iconFontFamily,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBudget(String budgetId, BuildContext context) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(local.deleteBudget),
        content: Text(local.confirmDeleteBudget),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<BudgetViewModel>().deleteBudget(budgetId);
              } finally {
                Navigator.pop(context);
              }
            },
            child:
                Text(local.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BudgetModel budget, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddBudgetSheet(
        categoryName: budget.category,
        categoryIcon: Icons.category,
        existingBudget: budget,
      ),
    );
  }

// void _manageCollaborators(BudgetModel budget,BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) => CollaboratorManagementDialog(
//       budget: budget,
//       onSave: (updatedCollaborators) async {
//         final updatedBudget = budget.copyWith(
//           collaborators: updatedCollaborators,
//         );
//         await context.read<BudgetViewModel>().updateBudget(updatedBudget);
//       },
//     ),
//   );
// }
}
