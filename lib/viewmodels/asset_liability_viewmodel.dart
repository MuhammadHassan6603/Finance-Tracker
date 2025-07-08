import 'package:finance_tracker/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import '../data/models/asset_liability_model.dart';
import '../data/repositories/asset_liability_repository.dart';
import '../core/constants/console.dart';
import 'auth_viewmodel.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../viewmodels/account_card_viewmodel.dart';

class NetWorthHistory {
  final DateTime date;
  final double amount;
  final double percentageChange;

  NetWorthHistory({
    required this.date,
    required this.amount,
    required this.percentageChange,
  });
}

class AssetLiabilityViewModel extends ChangeNotifier {
  final AssetLiabilityRepository _repository;
  final AuthViewModel _authViewModel;
  final NotificationService _notificationService;

  List<AssetLiabilityModel> _items = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription<List<AssetLiabilityModel>>? _subscription;
  AuthViewModel get authViewModel => _authViewModel;

  List<AssetLiabilityModel> get assets =>
      _items.where((item) => item.isAsset).toList();

  List<AssetLiabilityModel> get liabilities =>
      _items.where((item) => !item.isAsset).toList();

  AssetLiabilityViewModel({
    required AuthViewModel authViewModel,
    AssetLiabilityRepository? repository,
    NotificationService? notificationService,
  })  : _authViewModel = authViewModel,
        _repository = repository ?? AssetLiabilityRepository(),
        _notificationService = notificationService ?? NotificationService() {
    _init();
  }

  // Public properties
  List<AssetLiabilityModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalAssets =>
      _items.where((i) => i.isAsset).fold(0.0, (sum, i) => sum + i.amount);
  double get totalLiabilities =>
      _items.where((i) => !i.isAsset).fold(0.0, (sum, i) => sum + i.amount);
  double get netWorth => totalAssets - totalLiabilities;

  AssetLiabilityRepository get repository => _repository;

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadItems();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadItems();
    } else {
      _items = [];
      notifyListeners();
    }
  }

  Future<void> _loadItems() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      if (!_disposed) notifyListeners();

      _subscription?.cancel();
      _subscription = _repository.getAssetsLiabilities(userId).listen(
        (items) {
          if (_disposed) return;
          _items = items;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          if (_disposed) return;
          console('Asset/Liability stream error: $error',
              type: DebugType.error);
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (_disposed) return;
      console('Asset/Liability load error: $e', type: DebugType.error);
      _error = 'Failed to load items';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssetLiability(AssetLiabilityModel item) async {
    if (_disposed) return false;
    final user = _authViewModel.currentUser;
    if (user == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newItem = item.copyWith(userId: user.id);
      await _repository.addAssetLiability(newItem);
      await scheduleNotifications(newItem);
      return true;
    } catch (e) {
      console('Asset/Liability creation error: $e', type: DebugType.error);
      _error = 'Failed to create item: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> updateAssetLiability(AssetLiabilityModel item) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate the update
      if (item.name.isEmpty) {
        throw Exception('Name cannot be empty');
      }
      if (item.amount < 0) {
        throw Exception('Amount cannot be negative');
      }

      // Update in repository
      await _repository.updateAssetLiability(item);

      // Update in local state
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }

      await scheduleNotifications(item);
      return true;
    } catch (e) {
      console('Asset/Liability update error: $e', type: DebugType.error);
      _error = 'Failed to update item: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> toggleActiveStatus(String id, bool isActive) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.toggleActiveStatus(id, isActive);
      return true;
    } catch (e) {
      console('Status toggle error: $e', type: DebugType.error);
      _error = 'Failed to update status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> deleteAssetLiability(String id, {AccountCardViewModel? accountCardVM}) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Find the liability to be deleted
      final liabilityIndex = _items.indexWhere((item) => item.id == id);
      if (liabilityIndex != -1) {
        final liability = _items[liabilityIndex];
        if (!liability.isAsset && liability.type == 'Credit Card' && liability.cardId != null && accountCardVM != null) {
          final cardIndex = accountCardVM.accountCards.indexWhere((c) => c.id == liability.cardId);
          if (cardIndex != -1) {
            final card = accountCardVM.accountCards[cardIndex];
            final updatedCard = card.copyWith(balance: card.balance + liability.amount);
            await accountCardVM.updateAccountCard(updatedCard);
          }
        }
      }

      await _repository.deleteAssetLiability(id);
      return true;
    } catch (e) {
      console('Asset/Liability deletion error: $e', type: DebugType.error);
      _error = 'Failed to delete item: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authViewModel.removeListener(_authStateChanged);
    _disposed = true;
    super.dispose();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reloadItems() {
    if (!_isLoading && !_disposed) {
      _loadItems();
    }
  }

  Future<void> loadAssetLiabilities() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Trigger reload through the stream subscription
      _loadItems();
      _error = null;
    } catch (e) {
      _error = 'Failed to load assets/liabilities: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double get oneMonthGrowth => netWorthHistory.isNotEmpty 
      ? netWorthHistory.last.percentageChange 
      : 0.0;

  double get sixMonthGrowth {
    if (netWorthHistory.length < 6) return 0.0;
    final current = netWorthHistory.last.amount;
    final past = netWorthHistory[netWorthHistory.length - 6].amount;
    return past != 0 ? ((current - past) / past.abs()) * 100 : 0.0;
  }

  double get oneYearGrowth {
    if (netWorthHistory.isEmpty) return 0.0;
    final current = netWorthHistory.last.amount;
    final past = netWorthHistory.first.amount;
    return past != 0 ? ((current - past) / past.abs()) * 100 : 0.0;
  }

  double get financialHealthScore {
    if (totalAssets == 0) return 0.0;

    // Calculate debt-to-asset ratio
    final double debtToAssetRatio = totalLiabilities / totalAssets;

    // Calculate savings rate (simplified for this example)
    final double savingsRate = 0.25; // Assume 25% savings rate

    // Calculate emergency fund coverage (simplified for this example)
    final double emergencyFundCoverage = 3.0; // Assume 3 months of expenses

    // Calculate investment rate (simplified for this example)
    final double investmentRate = 0.15; // Assume 15% investment rate

    // Calculate financial health score (weighted average)
    final double score = (0.4 * (1 - debtToAssetRatio)) +
        (0.3 * savingsRate) +
        (0.2 * (emergencyFundCoverage / 6)) +
        (0.1 * investmentRate);

    return score.clamp(0.0, 1.0); // Ensure score is between 0 and 1
  }

  String get financialHealthStatus {
    if (financialHealthScore >= 0.8) return 'Excellent';
    if (financialHealthScore >= 0.6) return 'Good';
    if (financialHealthScore >= 0.4) return 'Moderate';
    return 'Needs Attention';
  }

  Color get financialHealthColor {
    if (financialHealthScore >= 0.8) return Colors.green;
    if (financialHealthScore >= 0.6) return Colors.greenAccent;
    if (financialHealthScore >= 0.4) return Colors.orange;
    return Colors.red;
  }

  double get debtToAssetRatio {
    return totalAssets > 0 ? totalLiabilities / totalAssets : 0;
  }

  List<NetWorthHistory> get netWorthHistory {
    final now = DateTime.now();
    final history = <NetWorthHistory>[];
    double previousNetWorth = 0;

    // Generate monthly history for the last 12 months
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i);
      final endDate = DateTime(date.year, date.month + 1, 0);
      
      final monthlyAssets = _items
          .where((item) => item.isAsset && item.updatedAt.isBefore(endDate))
          .fold(0.0, (sum, item) => sum + item.amount);
      
      final monthlyLiabilities = _items
          .where((item) => !item.isAsset && item.updatedAt.isBefore(endDate))
          .fold(0.0, (sum, item) => sum + item.amount);
      
      final monthlyNetWorth = monthlyAssets - monthlyLiabilities;
      final percentageChange = previousNetWorth != 0 
          ? ((monthlyNetWorth - previousNetWorth) / previousNetWorth.abs()) * 100
          : 0.0;

      history.insert(0, NetWorthHistory(
        date: date,
        amount: monthlyNetWorth,
        percentageChange: percentageChange,
      ));

      previousNetWorth = monthlyNetWorth;
    }

    return history;
  }

  // Getter for health color
  Color get healthColor {
    switch (financialHealthStatus) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.greenAccent;
      case 'Moderate':
        return Colors.orange;
      case 'Risky':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double get investmentRate {
    final totalInvestments = assets.fold(0.0, (sum, asset) => sum + asset.currentValue);
    final totalNetWorth = netWorth;
    return totalNetWorth > 0 ? totalInvestments / totalNetWorth : 0.0;
  }

  Future<void> scheduleNotifications(AssetLiabilityModel item) async {
    final topic = '${item.isAsset ? "asset" : "liability"}_${item.id}';

    for (final preference in item.trackingPreferences) {
      switch (preference) {
        case 'Value Updates':
          // Schedule local notification
          await _notificationService.scheduleAssetLiabilityNotification(
            id: item.hashCode + 100,
            title: '${item.isAsset ? "Asset" : "Liability"} Value Update',
            body: 'Time to update the value of ${item.name}',
            scheduledDate: DateTime.now().add(const Duration(days: 30)),
            itemId: item.id,
            type: item.isAsset ? 'asset' : 'liability',
          );

          // Send push notification
          await _notificationService.sendAssetLiabilityPushNotification(
            title: '${item.isAsset ? "Asset" : "Liability"} Value Update',
            body: 'Time to update the value of ${item.name}',
            topic: topic,
            itemId: item.id,
            type: item.isAsset ? 'asset' : 'liability',
            additionalData: {'type': 'value_update'},
          );
          break;

        case 'Payment Reminders':
          if (!item.isAsset && item.paymentSchedule != null) {
            final nextPaymentDate = _calculateNextPaymentDate(
              DateTime.now(),
              item.paymentSchedule!,
            );

            // Schedule local notification
            await _notificationService.scheduleAssetLiabilityNotification(
              id: item.hashCode + 200,
              title: 'Payment Due',
              body: 'Payment is due for ${item.name}',
              scheduledDate: nextPaymentDate,
              itemId: item.id,
              type: 'liability',
            );

            // Send push notification
            await _notificationService.sendAssetLiabilityPushNotification(
              title: 'Payment Due',
              body: 'Payment is due for ${item.name}',
              topic: topic,
              itemId: item.id,
              type: 'liability',
              additionalData: {
                'type': 'payment_reminder',
                'dueDate': nextPaymentDate.toIso8601String(),
              },
            );
          }
          break;

        // ... similar cases for other preferences ...
      }
    }
  }
   DateTime _calculateNextPaymentDate(DateTime currentDate, String schedule) {
    switch (schedule) {
      case 'Monthly':
        return DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
      case 'Quarterly':
        return DateTime(currentDate.year, currentDate.month + 3, currentDate.day);
      case 'Yearly':
        return DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
      default:
        return currentDate;
    }
  }
}
