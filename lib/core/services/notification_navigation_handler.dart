// lib/services/notification_navigation_handler.dart
import 'package:flutter/material.dart';

class NotificationNavigationHandler {
  final BuildContext context;

  NotificationNavigationHandler(this.context);

  void handleNavigation(Map<String, dynamic> data) {
    String? screenName = data['screen'];
    String? itemId = data['id'];

    switch (screenName) {
      case 'transaction_details':
        Navigator.pushNamed(context, '/transaction/details',
            arguments: {'transactionId': itemId});
        break;

      case 'budget_alert':
        Navigator.pushNamed(context, '/budget/overview',
            arguments: {'categoryId': data['category_id']});
        break;

      case 'bill_reminder':
        Navigator.pushNamed(context, '/bills/upcoming',
            arguments: {'billId': itemId});
        break;

      case 'spending_insight':
        Navigator.pushNamed(
          context,
          '/insights/spending',
        );
        break;

      case 'investment_update':
        Navigator.pushNamed(context, '/investments/details',
            arguments: {'assetId': itemId});
        break;

      default:
        Navigator.pushNamed(context, '/notifications');
    }
  }
}
