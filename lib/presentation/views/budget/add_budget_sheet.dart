import 'package:finance_tracker/core/constants/categories_list.dart';
import 'package:finance_tracker/core/services/local_notification_service.dart';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/data/models/budget_model.dart';
import 'package:finance_tracker/presentation/views/budget/widgets/budget_components.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodels/budget_viewmodel.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../core/utils/helpers.dart';

class AddBudgetSheet extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;
  final BudgetModel? existingBudget;

  const AddBudgetSheet({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    this.existingBudget,
  });

  @override
  State<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _categoryFormKey = GlobalKey<FormState>();
  final _amountFormKey = GlobalKey<FormState>();
  final _periodFormKey = GlobalKey<FormState>();

  // Form data
  String _category = '';
  IconData _categoryIcon = Icons.category;
  String _categoryIconFontFamily = 'FontAwesomeSolid';
  String _categoryIconCode = Icons.category.codePoint.toString();
  double _budgetAmount = 0;
  String _period = 'Monthly';
  bool _isRecurring = false;
  final List<String> _collaborators = [];
  final List<String> _alerts = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  TextStyle get titleStyle => Theme.of(context).textTheme.titleMedium!.copyWith(
        color: isDarkMode
            ? ThemeConstants.textPrimaryDark
            : ThemeConstants.textPrimaryLight,
      );

  BudgetViewModel get viewModel =>
      Provider.of<BudgetViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    final budget = widget.existingBudget;

    if (budget != null) {
      _category = budget.category;
      _categoryIconCode = budget.icon;
      _categoryIcon = IconData(int.parse(_categoryIconCode),
          fontFamily: 'FontAwesomeSolid');
      _budgetAmount = budget.amount;
      _period = budget.periodType;
      _isRecurring = budget.isRecurring;
      _collaborators.addAll(budget.collaborators);
      _alerts.addAll(budget.alerts);
      _startDate = budget.startDate;
      _endDate = budget.endDate;
    } else {
      _category = widget.categoryName;
      _categoryIcon = widget.categoryIcon;
      _categoryIconCode = widget.categoryIcon.codePoint.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDarkMode ? ThemeConstants.surfaceDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            _buildTitleBar(),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom: 80.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildStepIndicator(),
                            const SizedBox(height: 24),
                            _buildCurrentStepContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? ThemeConstants.surfaceDark
                            : Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: _buildNavigationButtons(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStepContent();
      case 1:
        return _buildAmountStepContent();
      case 2:
        return _buildPeriodStepContent();
      case 3:
        return _buildRecurringStepContent();
      case 4:
        return _buildCollaboratorsStepContent();
      case 5:
        return _buildAlertsStepContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Category', style: titleStyle),
        const SizedBox(height: 16),
        _buildCategoryGrid(),
        if (_category == 'Other') _buildCustomCategoryField(),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = CategoryList.categories.skip(9).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategoryItem(index + 9),
    );
  }

  Widget _buildCategoryItem(int index) {
    final category = CategoryList.categories[index];
    final isSelected = _category == category['title'];

    return InkWell(
      onTap: () => _handleCategorySelection(category),
      child: Container(
        decoration: _buildCategoryDecoration(isSelected),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'] as IconData,
                color: _getCategoryIconColor(isSelected), size: 20),
            const SizedBox(height: 8),
            Text(category['title'] as String,
                textAlign: TextAlign.center,
                style: _getCategoryTextStyle(isSelected)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCategoryDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: isSelected
          ? Border.all(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            )
          : null,
    );
  }

  Widget _buildPeriodStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Period', style: titleStyle),
        const SizedBox(height: 16),
        BudgetRadioListTile(
          title: 'Monthly',
          value: 'Monthly',
          groupValue: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        BudgetRadioListTile(
          title: 'Quarterly',
          value: 'Quarterly',
          groupValue: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        BudgetRadioListTile(
          title: 'Yearly',
          value: 'Yearly',
          groupValue: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        BudgetRadioListTile(
          title: 'Custom',
          value: 'Custom',
          groupValue: _period,
          onChanged: (v) => setState(() => _period = v),
        ),
        if (_period == 'Custom') _buildCustomDateFields(),
      ],
    );
  }

  Widget _buildAlertsStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alerts & Notifications', style: titleStyle),
        const SizedBox(height: 16),
        BudgetCheckboxListTile(
          title: '80% of budget used',
          value: _alerts.contains('80%'),
          onChanged: (v) => _updateAlerts('80%', v),
        ),
        BudgetCheckboxListTile(
          title: '90% of budget used',
          value: _alerts.contains('90%'),
          onChanged: (v) => _updateAlerts('90%', v),
        ),
        BudgetCheckboxListTile(
          title: 'Budget exceeded',
          value: _alerts.contains('exceeded'),
          onChanged: (v) => _updateAlerts('exceeded', v),
        ),
        const SizedBox(height: 16),
        _buildCustomAlertField(),
      ],
    );
  }

  Widget _buildAmountStepContent() {
    return Form(
      key: _amountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Amount *',
            style: titleStyle,
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: Helpers.storeCurrency(context),
              labelText: 'Enter Budget Amount',
              border: const OutlineInputBorder(),
              helperText: 'Set your budget limit for this category',
              errorStyle: const TextStyle(color: Colors.red),
              labelStyle: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
              ),
              helperStyle: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textSecondaryDark
                    : ThemeConstants.textSecondaryLight,
              ),
            ),
            style: TextStyle(
              color: isDarkMode
                  ? ThemeConstants.textPrimaryDark
                  : ThemeConstants.textPrimaryLight,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a budget amount';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid number';
              }
              if (amount <= 0) {
                return 'Amount must be greater than 0';
              }
              if (amount > 999999999) {
                return 'Amount is too large';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _budgetAmount = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurring Options',
          style: titleStyle,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Make this budget recurring?'),
          subtitle: const Text('Budget will automatically reset each period'),
          value: _isRecurring,
          onChanged: (bool value) {
            setState(() {
              _isRecurring = value;
            });
          },
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          const Text(
            'Budget will automatically reset at the beginning of each period',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Carry over remaining balance'),
            value: false, // Add state variable if needed
            onChanged: (bool? value) {
              // Handle carry over option
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCollaboratorsStepContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collaborators',
          style: titleStyle,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Add Collaborators'),
          subtitle: const Text('Share this budget with others'),
          trailing: IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Show collaborator selection dialog
              _showCollaboratorDialog();
            },
          ),
        ),
        if (_collaborators.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _collaborators
                .map(
                  (collaborator) => Chip(
                    label: Text(collaborator),
                    onDeleted: () {
                      setState(() {
                        _collaborators.remove(collaborator);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _showCollaboratorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Collaborator'),
        content: SizedBox(
          width: double.maxFinite,
          child: CustomTextField(
            labelText: 'Enter name',
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _collaborators.add(value);
                });
                Navigator.pop(context);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle collaborator addition
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveBudget() async {
    if (!_validateCurrentStep()) {
      return;
    }

    // Validate all required fields one final time
    if (_category.isEmpty || _budgetAmount <= 0) {
      ToastUtils.showErrorToast(
        context,
        title: 'Validation Error',
        description: 'Please fill in all required fields',
      );
      return;
    }

    if (_period == 'Custom' && _startDate.isAfter(_endDate)) {
      ToastUtils.showErrorToast(
        context,
        title: 'Invalid Date Range',
        description: 'Start date must be before end date',
      );
      return;
    }

    final viewModel = Provider.of<BudgetViewModel>(context, listen: false);

    if (viewModel.isLoading) {
      return;
    }

    try {
      // Check if budget exists for this category in the selected month
      if (widget.existingBudget == null &&
          viewModel.isBudgetExistsForCategory(_category, _startDate)) {
        ToastUtils.showErrorToast(
          context,
          title: 'Duplicate Budget',
          description:
              'A budget for this category already exists in the selected month',
        );
        return;
      }

      final budget = widget.existingBudget?.copyWith(
            category: _category,
            amount: _budgetAmount,
            startDate: _startDate,
            endDate: _endDate,
            periodType: _period,
            customPeriod:
                _period == 'Custom' ? _getCustomPeriodDescription() : null,
            isRecurring: _isRecurring,
            collaborators: _collaborators,
            alerts: _alerts,
            isActive: true,
            updatedAt: DateTime.now(),
            icon: _categoryIconCode,
            iconFontFamily: _categoryIconFontFamily,
          ) ??
          BudgetModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: viewModel.authViewModel.currentUser!.id,
            category: _category,
            amount: _budgetAmount,
            startDate: _startDate,
            endDate: _endDate,
            periodType: _period,
            customPeriod:
                _period == 'Custom' ? _getCustomPeriodDescription() : null,
            isRecurring: _isRecurring,
            collaborators: _collaborators,
            alerts: _alerts,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            icon: _categoryIconCode,
            iconFontFamily: _categoryIconFontFamily,
          );

      final success = widget.existingBudget != null
          ? await viewModel.updateBudget(budget)
          : await viewModel.createBudget(budget);

      if (!success) {
        ToastUtils.showErrorToast(
          context,
          title: 'Error',
          description:
              viewModel.error ?? 'Failed to save budget. Please try again.',
        );
        return;
      }

      if (mounted && success) {
        Navigator.pop(context);
        ToastUtils.showSuccessToast(
          context,
          title: 'Success',
          description: widget.existingBudget != null
              ? 'Budget updated successfully'
              : 'Budget created successfully',
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('already exists')) {
        ToastUtils.showErrorToast(
          context,
          title: 'Duplicate Budget',
          description:
              'A budget for this category already exists in the selected month',
        );
      } else {
        ToastUtils.showErrorToast(
          context,
          title: 'Error',
          description: errorMessage.replaceAll('Exception: ', ''),
        );
      }
    }
  }

  String _getCustomPeriodDescription() {
    final difference = _endDate.difference(_startDate);
    if (difference.inDays <= 31) return '${difference.inDays} days';
    if (difference.inDays <= 365) {
      return '${(difference.inDays / 30).round()} months';
    }
    return '${(difference.inDays / 365).round()} years';
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Set Budget',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : ThemeConstants.textPrimaryLight,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextButton(
              onPressed: _currentStep == 5 ? _saveBudget : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _currentStep == 5
                      ? ThemeConstants.primaryColor
                      : isDarkMode
                          ? Colors.grey[600]
                          : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(6, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? Theme.of(context).primaryColor
                  : isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 100,
          child: _currentStep > 0
              ? OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeConstants.primaryColor,
                    side: const BorderSide(color: ThemeConstants.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Back'),
                )
              : const SizedBox(),
        ),
        SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () {
              if (_validateCurrentStep()) {
                if (_currentStep < 5) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  _saveBudget();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_currentStep == 5 ? 'Save' : 'Continue'),
          ),
        ),
      ],
    );
  }

  void _handleCategorySelections(dynamic category) {
    setState(() {
      _category = category['title'] as String;
      _categoryIcon = category['icon'] as IconData;
      _categoryIconCode = _categoryIcon.codePoint.toString();
    });
  }

  void _handleCategorySelection(dynamic category) {
    setState(() {
      _category = category['title'] as String;
      _categoryIcon = category['icon'] as IconData;
      _categoryIconCode = _categoryIcon.codePoint.toString();
      _categoryIconFontFamily = _categoryIcon.fontFamily ?? 'FontAwesomeSolid';
    });
  }

  Color? _getCategoryIconColor(bool isSelected) {
    return isSelected
        ? Theme.of(context).primaryColor
        : isDarkMode
            ? ThemeConstants.textPrimaryDark
            : Colors.grey[700];
  }

  TextStyle _getCategoryTextStyle(bool isSelected) {
    return TextStyle(
      color: isSelected
          ? Theme.of(context).primaryColor
          : isDarkMode
              ? ThemeConstants.textPrimaryDark
              : Colors.grey[800],
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      fontSize: 12,
    );
  }

  void _updateAlerts(String alert, bool? value) {
    setState(() {
      if (value ?? false) {
        _alerts.add(alert);
      } else {
        _alerts.remove(alert);
      }
    });
  }

  Widget _buildCustomCategoryField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Enter Custom Category',
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(
          color: isDarkMode
              ? ThemeConstants.textSecondaryDark
              : ThemeConstants.textSecondaryLight,
        ),
      ),
      style: TextStyle(
        color: isDarkMode
            ? ThemeConstants.textPrimaryDark
            : ThemeConstants.textPrimaryLight,
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          setState(() {
            _category = value;
          });
        }
      },
    );
  }

  Widget _buildCustomDateFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DatePickerField(
              label: 'Start Date',
              value: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DatePickerField(
              label: 'End Date',
              value: _endDate,
              onChanged: (date) => setState(() => _endDate = date),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAlertField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Custom Alert Threshold (%)',
        border: OutlineInputBorder(),
        helperText: 'Enter a custom percentage for alerts',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.isNotEmpty) {
          final threshold = int.tryParse(value);
          if (threshold != null && threshold > 0 && threshold < 100) {
            setState(() {
              _alerts.add('$threshold%');
            });
          }
        }
      },
    );
  }

  Widget DatePickerField({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: DateFormat('MMM dd, yyyy').format(value),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != value) {
          onChanged(picked);
        }
      },
    );
  }

  IconData _getIconForCategory(String category) {
    return CategoryList.categories.firstWhere(
      (c) => c['title'] == category,
      orElse: () => {'icon': Icons.category},
    )['icon'] as IconData;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Category step
        if (_category.isEmpty) {
          ToastUtils.showErrorToast(
            context,
            title: 'Required Field',
            description: 'Please select a category',
          );
          return false;
        }
        return true;

      case 1: // Amount step
        if (_amountFormKey.currentState?.validate() ?? false) {
          if (_budgetAmount <= 0) {
            ToastUtils.showErrorToast(
              context,
              title: 'Invalid Amount',
              description: 'Budget amount must be greater than 0',
            );
            return false;
          }
          return true;
        }
        return false;

      case 2: // Period step
        if (_period == 'Custom') {
          if (_startDate.isAfter(_endDate)) {
            ToastUtils.showErrorToast(
              context,
              title: 'Invalid Date Range',
              description: 'Start date must be before end date',
            );
            return false;
          }
          if (_endDate.difference(_startDate).inDays < 1) {
            ToastUtils.showErrorToast(
              context,
              title: 'Invalid Date Range',
              description: 'Budget period must be at least 1 day',
            );
            return false;
          }
        }
        return true;

      default:
        return true;
    }
  }
}
