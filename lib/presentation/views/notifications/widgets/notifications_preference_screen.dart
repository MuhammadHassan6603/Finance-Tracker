// lib/screens/notification_preferences_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final NotificationService _notificationService = NotificationService();

  // Notification preference states
  bool _budgetAlerts = true;
  bool _billReminders = true;
  bool _investmentUpdates = false;
  bool _spendingInsights = true;
  bool _savingsGoalUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Budget Alerts'),
            subtitle: const Text(
                'Get notified when you approach or exceed budget limits'),
            value: _budgetAlerts,
            onChanged: (value) async {
              if (value) {
                await _notificationService.subscribeToTopic('budget_alerts');
              } else {
                await _notificationService
                    .unsubscribeFromTopic('budget_alerts');
              }
              setState(() {
                _budgetAlerts = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Bill Reminders'),
            subtitle:
                const Text('Receive reminders for upcoming bill payments'),
            value: _billReminders,
            onChanged: (value) async {
              if (value) {
                await _notificationService.subscribeToTopic('bill_reminders');
              } else {
                await _notificationService
                    .unsubscribeFromTopic('bill_reminders');
              }
              setState(() {
                _billReminders = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Investment Updates'),
            subtitle: const Text(
                'Get notifications about your investment portfolio performance'),
            value: _investmentUpdates,
            onChanged: (value) async {
              if (value) {
                await _notificationService
                    .subscribeToTopic('investment_updates');
              } else {
                await _notificationService
                    .unsubscribeFromTopic('investment_updates');
              }
              setState(() {
                _investmentUpdates = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Spending Insights'),
            subtitle:
                const Text('Receive insights about your spending patterns'),
            value: _spendingInsights,
            onChanged: (value) async {
              if (value) {
                await _notificationService
                    .subscribeToTopic('spending_insights');
              } else {
                await _notificationService
                    .unsubscribeFromTopic('spending_insights');
              }
              setState(() {
                _spendingInsights = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Savings Goal Updates'),
            subtitle: const Text(
                'Get updates on your progress towards savings goals'),
            value: _savingsGoalUpdates,
            onChanged: (value) async {
              if (value) {
                await _notificationService.subscribeToTopic('savings_goals');
              } else {
                await _notificationService
                    .unsubscribeFromTopic('savings_goals');
              }
              setState(() {
                _savingsGoalUpdates = value;
              });
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Notification Schedule',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Configure when you receive notifications'),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly Summary Day'),
                DropdownButton<String>(
                  value: 'Sunday',
                  isExpanded: true,
                  items: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                  ]
                      .map((day) => DropdownMenuItem(
                            value: day,
                            child: Text(day),
                          ))
                      .toList(),
                  onChanged: (value) {
                    // Update weekly summary day preference
                  },
                ),
                const SizedBox(height: 16),
                const Text('Quiet Hours'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '22:00',
                        decoration: const InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: '08:00',
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Save all notification preferences
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Notification preferences saved')),
                );
              },
              child: const Text('Save Preferences'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
