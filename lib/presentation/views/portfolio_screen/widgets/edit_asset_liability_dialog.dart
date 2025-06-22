import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/asset_liability_model.dart';
import '../../../../core/utils/helpers.dart';
import 'package:gap/gap.dart';

class EditAssetLiabilityDialog extends StatefulWidget {
  final AssetLiabilityModel item;

  const EditAssetLiabilityDialog({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<EditAssetLiabilityDialog> createState() => _EditAssetLiabilityDialogState();
}

class _EditAssetLiabilityDialogState extends State<EditAssetLiabilityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _amountController.text = widget.item.amount.toString();
    _isActive = widget.item.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.item.isAsset ? 'Asset' : 'Liability'}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: const OutlineInputBorder(),
                  prefixText: Helpers.storeCurrency(context),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const Gap(16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final updatedItem = widget.item.copyWith(
                name: _nameController.text,
                amount: double.tryParse(_amountController.text) ?? widget.item.amount,
                isActive: _isActive,
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context, updatedItem);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 