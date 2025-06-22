import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/core/services/notification_settings_service.dart';

class NotificationToggle extends StatefulWidget {
  final String type;
  
  const NotificationToggle({
    super.key,
    required this.type,
  });

  @override
  State<NotificationToggle> createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<NotificationToggle> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = _getInitialValue();
  }

  bool _getInitialValue() {
    final settingsService = Provider.of<NotificationSettingsService>(context, listen: false);
    switch (widget.type) {
      case 'budget_limits':
        return settingsService.budgetLimitsEnabled;
      case 'bill_payment':
        return settingsService.billPaymentEnabled;
      default:
        return true;
    }
  }

  Future<void> _toggleNotification(bool value) async {
    final settingsService = Provider.of<NotificationSettingsService>(context, listen: false);
    
    setState(() {
      _isEnabled = value;
    });

    switch (widget.type) {
      case 'budget_limits':
        await settingsService.setBudgetLimitsEnabled(value);
        break;
      case 'bill_payment':
        await settingsService.setBillPaymentEnabled(value);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isEnabled,
      onChanged: _toggleNotification,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
} 