import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/core/services/local_notification_service.dart';
import 'package:finance_tracker/core/utils/helpers.dart';
import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodels/asset_liability_viewmodel.dart';
import '../../../../data/models/asset_liability_model.dart';

import '../../../../core/constants/theme_constants.dart';

class AddAssetLiabilitySheet extends StatefulWidget {
  final bool isAsset;

  const AddAssetLiabilitySheet({
    super.key,
    required this.isAsset,
  });

  @override
  State<AddAssetLiabilitySheet> createState() => _AddAssetLiabilitySheetState();
}

class _AddAssetLiabilitySheetState extends State<AddAssetLiabilitySheet> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _typeFormKey = GlobalKey<FormState>();
  final _amountFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();

  // Form data
  String _type = '';
  double _amount = 0;
  String _name = '';
  DateTime _startDate = DateTime.now();
  double? _interestRate;
  String? _paymentSchedule;
  List<String> _attachments = [];
  List<String> _trackingPreferences = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            Material(
              color: Theme.of(context).brightness == Brightness.dark
                  ? ThemeConstants.surfaceDark
                  : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: _buildMainContent(context),
            ),
            if (viewModel.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (viewModel.error != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: viewModel.clearError,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SizedBox(
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
                // Main scrollable content
                SingleChildScrollView(
              child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      // Add bottom padding to prevent content from being hidden behind buttons
                      bottom: 80.0,
                    ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: index <= _currentStep
                                    ? Theme.of(context).primaryColor
                                        : Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                      const Gap(24),
                      if (_currentStep == 0) _buildTypeStepContent(),
                      if (_currentStep == 1) _buildAmountStepContent(),
                      if (_currentStep == 2) _buildDetailsStepContent(),
                      if (_currentStep == 3) _buildAttachmentsStepContent(),
                      if (_currentStep == 4) _buildTrackingStepContent(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fixed navigation buttons at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? ThemeConstants.surfaceDark
                          : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
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
                                      side: const BorderSide(
                                          color: ThemeConstants.primaryColor),
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
                                  if (_currentStep < 4) {
                                    setState(() {
                                      _currentStep++;
                                    });
                                  } else {
                                    _saveAssetLiability();
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 48),
                              ),
                            child: Text(_currentStep == 4 ? 'Save' : 'Continue'),
                            ),
                          ),
                        ],
              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Consumer<AssetLiabilityViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Add ${widget.isAsset ? "Asset" : "Liability"}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? ThemeConstants.textPrimaryDark
                            : ThemeConstants.textPrimaryLight,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              SizedBox(
                width: 80,
                child: TextButton(
                  onPressed: viewModel.isLoading ? null : _saveAssetLiability,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: viewModel.isLoading
                          ? Colors.grey
                          : (_currentStep == 4
                              ? ThemeConstants.primaryColor
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[600]
                                  : Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeStepContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final types =
        widget.isAsset ? AppConstants.assetsList : AppConstants.liabilityList;

    return Form(
      key: _typeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildReusableText('Type *'),
          const Gap(16),
          ...types.map(
            (type) => ListTile(
              title: Text(
                type,
                style: TextStyle(
                  color: isDarkMode
                      ? ThemeConstants.textPrimaryDark
                      : ThemeConstants.textPrimaryLight,
                ),
              ),
              leading: Radio<String>(
                value: type,
                groupValue: _type,
                activeColor: ThemeConstants.primaryColor,
                onChanged: (value) {
                  setState(() => _type = value!);
                },
              ),
            ),
          ),
          if (_type == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomTextField(
                labelText: 'Enter Custom Type *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a custom type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountStepContent() {
    return Form(
      key: _amountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildReusableText('Value/Amount *'),
          const Gap(16),
          CustomTextField(
            keyboardType: TextInputType.number,
            prefixText: Helpers.storeCurrency(context),
            labelText: widget.isAsset ? 'Asset Value' : 'Liability Amount',
            helperText:
                widget.isAsset ? 'Current market value' : 'Outstanding amount',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid number';
              }
              if (amount <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _amount = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStepContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildReusableText('Details'),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: 'Name/Description *',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name or description';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _name = value;
              });
            },
          ),
          const Gap(16),
          CustomTextField(
            labelText: 'Purchase/Start Date *',
            readOnly: true,
            validator: (value) {
              if (_startDate == null) {
                return 'Please select a date';
              }
              return null;
            },
            controller: TextEditingController(
              text: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                });
              }
            },
          ),
          if (!widget.isAsset) ...[
            const Gap(16),
            CustomTextField(
              keyboardType: TextInputType.number,
              labelText: 'Interest Rate (%) *',
              suffixText: '%',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an interest rate';
                }
                final rate = double.tryParse(value);
                if (rate == null) {
                  return 'Please enter a valid number';
                }
                if (rate < 0) {
                  return 'Interest rate cannot be negative';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _interestRate = double.tryParse(value);
                });
              },
            ),
            const Gap(16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Payment Schedule *',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? ThemeConstants.textSecondaryDark
                      : ThemeConstants.textSecondaryLight,
                ),
              ),
              value: _paymentSchedule,
              hint: const Text('Select payment frequency'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a payment schedule';
                }
                return null;
              },
              items: ['Monthly', 'Quarterly', 'Yearly']
                  .map((schedule) => DropdownMenuItem(
                        value: schedule,
                        child: Text(schedule),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _paymentSchedule = value;
                });
              },
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textPrimaryDark
                    : ThemeConstants.textPrimaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsStepContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildReusableText('Documents/Attachments'),
        const Gap(16),
        ElevatedButton.icon(
          onPressed: () async {
            // Implement file picking logic
            // You'll need to add file_picker package for this
            // final result = await FilePicker.platform.pickFiles();
            // if (result != null) {
            //   setState(() {
            //     _attachments.add(result.files.single.path!);
            //   });
            // }
          },
          icon: const Icon(Icons.attach_file),
          label: const Text('Add Document'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDarkMode ? ThemeConstants.cardDark : Colors.grey[200],
            foregroundColor:
                isDarkMode ? ThemeConstants.textPrimaryDark : Colors.grey[800],
          ),
        ),
        if (_attachments.isNotEmpty) ...[
          const Gap(16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final attachment = _attachments[index];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(
                  attachment.split('/').last,
                  style: TextStyle(
                    color: isDarkMode
                        ? ThemeConstants.textPrimaryDark
                        : Colors.grey[800],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _attachments.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTrackingStepContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final trackingOptions = [
      'Value Updates',
      'Payment Reminders',
      'Document Expiry',
      'Interest Rate Changes',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking Preferences',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDarkMode
                    ? ThemeConstants.textPrimaryDark
                    : ThemeConstants.textPrimaryLight,
              ),
        ),
        const Gap(16),
        ...trackingOptions.map(
          (option) => CheckboxListTile(
            title: Text(
              option,
              style: TextStyle(
                color: isDarkMode
                    ? ThemeConstants.textPrimaryDark
                    : ThemeConstants.textPrimaryLight,
              ),
            ),
            value: _trackingPreferences.contains(option),
            onChanged: (bool? value) {
              setState(() {
                if (value ?? false) {
                  _trackingPreferences.add(option);
                } else {
                  _trackingPreferences.remove(option);
                }
              });
            },
          ),
        ),
        const Gap(16),
        CustomTextField(
          labelText: 'Custom Tracking Note',
          maxLines: 2,
          helperText: 'Add any specific tracking requirements',
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _trackingPreferences.add('Custom: $value');
              });
            }
          },
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Type step
        if (_type.isEmpty) {
          ToastUtils.showErrorToast(
            context,
            title: 'Validation Error',
            description: 'Please select a type',
          );
          return false;
        }
        return true;

      case 1: // Amount step
        if (_amount <= 0) {
          ToastUtils.showErrorToast(
            context,
            title: 'Validation Error',
            description: 'Please enter a valid amount greater than 0',
          );
          return false;
        }
        return true;

      case 2: // Details step
        if (_name.trim().isEmpty) {
          ToastUtils.showErrorToast(
            context,
            title: 'Validation Error',
            description: 'Please enter a name/description',
          );
          return false;
        }
        // Validate interest rate for liabilities
        if (!widget.isAsset && _interestRate == null) {
          ToastUtils.showErrorToast(
            context,
            title: 'Validation Error',
            description: 'Please enter an interest rate',
          );
          return false;
        }
        // Validate payment schedule for liabilities
        if (!widget.isAsset && (_paymentSchedule == null || _paymentSchedule!.isEmpty)) {
          ToastUtils.showErrorToast(
            context,
            title: 'Validation Error',
            description: 'Please select a payment schedule',
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _saveAssetLiability() async {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Validate all required fields one final time
      if (_type.isEmpty || _amount <= 0 || _name.trim().isEmpty) {
        ToastUtils.showErrorToast(
          context,
          title: 'Validation Error',
          description: 'Please fill in all required fields',
        );
        return;
      }

      if (!widget.isAsset && (_interestRate == null || _paymentSchedule == null)) {
        ToastUtils.showErrorToast(
          context,
          title: 'Validation Error',
          description: 'Please fill in all required liability fields',
        );
        return;
      }

      if (!mounted) return;

      final viewModel =
          Provider.of<AssetLiabilityViewModel>(context, listen: false);

      final newItem = AssetLiabilityModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: viewModel.authViewModel.currentUser!.id,
        isAsset: widget.isAsset,
        type: _type,
        amount: _amount,
        name: _name,
        startDate: _startDate,
        interestRate: _interestRate,
        paymentSchedule: _paymentSchedule,
        attachments: _attachments,
        trackingPreferences: _trackingPreferences,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final success = await viewModel.createAssetLiability(newItem);

      if (success) {
        // Notifications will be handled by the ViewModel
        if (mounted) {
          Navigator.pop(context);
          ToastUtils.showSuccessToast(
            context,
            title: 'Success',
            description: '${widget.isAsset ? "Asset" : "Liability"} added successfully',
          );
        }
      }
    }
  }

 

  double _calculatePaymentAmount() {
    if (_interestRate == null || _amount <= 0) return 0;
    // Simple interest calculation
    final annualInterest = _amount * (_interestRate! / 100);
    switch (_paymentSchedule) {
      case 'Monthly':
        return annualInterest / 12;
      case 'Quarterly':
        return annualInterest / 4;
      case 'Yearly':
        return annualInterest;
      default:
        return 0;
    }
  }

  Widget buildReusableText(String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDarkMode
                ? ThemeConstants.textPrimaryDark
                : ThemeConstants.textPrimaryLight,
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
