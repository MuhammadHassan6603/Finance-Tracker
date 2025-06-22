import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_bottom_sheet.dart';
import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../data/models/account_card_model.dart';
import '../../../generated/l10n.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form data
  String _transactionType = 'Expense';
  double _amount = 0;
  String _category = '';
  DateTime _date = DateTime.now();
  String _notes = '';
  List<String> _attachments = [];
  List<String> _splitWith = [];
  String? _selectedPaymentMethod;
  double? _availableBalance;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return CustomBottomSheet(
      title: localization.addTransaction,
      onSave: _currentStep == 5 ? _saveTransaction : null,
      children: [
        Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 5) {
              setState(() => _currentStep++);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          steps: [
            _buildTransactionTypeStep(),
            _buildPaymentMethodStep(),
            _buildAmountStep(),
            _buildCategoryStep(),
            _buildDateTimeStep(),
            _buildNotesStep(),
          ],
        ),
      ],
    );
  }

  Step _buildTransactionTypeStep() {
    final localization = AppLocalizations.of(context);
    return Step(
      title: const Text('Transaction Type'),
      content: SegmentedButton(
        segments: [
          ButtonSegment(value: 'Expense', label: const Text('Expense')),
          ButtonSegment(value: 'Income', label: const Text('Income')),
          ButtonSegment(value: 'Transfer', label: const Text('Transfer')),
        ],
        selected: {_transactionType},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _transactionType = newSelection.first;
            _selectedPaymentMethod = null;
            _availableBalance = null;
          });
        },
      ),
      isActive: _currentStep == 0,
    );
  }

  Step _buildPaymentMethodStep() {
    final viewModel = context.watch<AccountCardViewModel>();
    final cards = viewModel.accountCards;

    return Step(
      title: const Text('Payment Method'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Select Payment Method',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: 'Cash Wallet',
                child: Text('Cash Wallet'),
              ),
              ...cards.map((card) => DropdownMenuItem(
                    value: card.id,
                    child: Text('${card.name} (${card.number})'),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
                if (value == 'Cash Wallet') {
                  _availableBalance = 0; // You might want to fetch this from somewhere
                } else {
                  final selectedCard = cards.firstWhere(
                    (card) => card.id == value,
                    orElse: () => throw Exception('Card not found'),
                  );
                  _availableBalance = selectedCard.balance;
                }
              });
            },
          ),
          if (_availableBalance != null) ...[
            const SizedBox(height: 8),
            Text(
              'Available Balance: ₹${_availableBalance!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
      ),
      isActive: _currentStep == 1,
    );
  }

  Step _buildAmountStep() {
    return Step(
      title: const Text('Amount'),
      content: TextFormField(
        enabled: _selectedPaymentMethod != null,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixText: '₹ ',
          labelText: 'Enter Amount',
          border: const OutlineInputBorder(),
          helperText: _selectedPaymentMethod == null
              ? 'Please select a payment method first'
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an amount';
          }
          final amount = double.tryParse(value);
          if (amount == null) {
            return 'Please enter a valid number';
          }
          if (_transactionType == 'Expense' && 
              _availableBalance != null && 
              amount > _availableBalance!) {
            return 'Insufficient balance';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            _amount = double.tryParse(value) ?? 0;
          });
        },
      ),
      isActive: _currentStep == 2,
    );
  }

  Step _buildCategoryStep() {
    final categories = _transactionType == 'Expense'
        ? ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Other']
        : ['Salary', 'Investment', 'Gift', 'Other'];

    return Step(
      title: const Text('Category'),
      content: Column(
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _category == category,
                onSelected: (selected) {
                  setState(() {
                    _category = selected ? category : '';
                  });
                },
              );
            }).toList(),
          ),
          if (_category == 'Other')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter Custom Category',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
              ),
            ),
        ],
      ),
      isActive: _currentStep == 3,
    );
  }

  Step _buildDateTimeStep() {
    return Step(
      title: const Text('Date & Time'),
      content: Column(
        children: [
          ListTile(
            title: const Text('Date'),
            subtitle: Text(
              '${_date.day}/${_date.month}/${_date.year}',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _date = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    _date.hour,
                    _date.minute,
                  );
                });
              }
            },
          ),
          ListTile(
            title: const Text('Time'),
            subtitle: Text(
              '${_date.hour}:${_date.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_date),
              );
              if (picked != null) {
                setState(() {
                  _date = DateTime(
                    _date.year,
                    _date.month,
                    _date.day,
                    picked.hour,
                    picked.minute,
                  );
                });
              }
            },
          ),
        ],
      ),
      isActive: _currentStep == 4,
    );
  }

  Step _buildNotesStep() {
    return Step(
      title: const Text('Notes & Attachments'),
      content: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Add Notes',
              border: OutlineInputBorder(),
              hintText: 'Enter any additional details...',
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _notes = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              // Implement file picking logic
              // You'll need to add image_picker package for this
              // final ImagePicker picker = ImagePicker();
              // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              // if (image != null) {
              //   setState(() {
              //     _attachments.add(image.path);
              //   });
              // }
            },
            icon: const Icon(Icons.attach_file),
            label: const Text('Add Attachment'),
          ),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _attachments
                  .map(
                    (path) => Chip(
                      label: Text(path.split('/').last),
                      onDeleted: () {
                        setState(() {
                          _attachments.remove(path);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
      isActive: _currentStep == 5,
    );
  }

  @override
  void _saveTransaction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final viewModel = context.read<AccountCardViewModel>();
    final transaction = {
      'type': _transactionType,
      'amount': _amount,
      'category': _category,
      'date': _date,
      'notes': _notes,
      'attachments': _attachments,
      'splitWith': _splitWith,
      'paymentMethod': _selectedPaymentMethod,
    };

    try {
      if (_selectedPaymentMethod != null && _selectedPaymentMethod != 'Cash Wallet') {
        final card = viewModel.accountCards.firstWhere(
          (c) => c.id == _selectedPaymentMethod,
          orElse: () => throw Exception('Card not found'),
        );

        double newBalance;
        if (_transactionType == 'Expense') {
          newBalance = card.balance - _amount;
        } else if (_transactionType == 'Income') {
          newBalance = card.balance + _amount;
        } else {
          // Handle transfer case
          newBalance = card.balance - _amount;
        }

        final updatedCard = card.copyWith(
          balance: newBalance,
        );

        await viewModel.updateAccountCard(updatedCard);
      }

      if (mounted) {
        Navigator.pop(context, transaction);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
