import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/models/account_card_model.dart';
import '../data/repositories/account_card_repository.dart';
import '../core/constants/console.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'dart:async';

class AccountCardViewModel extends ChangeNotifier {
  final AccountCardRepository _repository;
  final AuthViewModel _authViewModel;
  List<AccountCardModel> _accountCards = [];
  AccountCardModel? _selectedAccountCard;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription<List<AccountCardModel>>? _cardsSubscription;

  AccountCardViewModel({
    AccountCardRepository? repository,
    required AuthViewModel authViewModel,
  })  : _repository = repository ?? AccountCardRepository(),
        _authViewModel = authViewModel {
    // Initialize by loading account cards if user is already authenticated
    if (_authViewModel.currentUser != null) {
      _loadAccountCards();
    }
  }

  // Getters
  List<AccountCardModel> get accountCards => _accountCards;
  AccountCardModel? get selectedAccountCard => _selectedAccountCard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _authViewModel.currentUser?.id;

  // Load account cards for the current user
  Future<void> _loadAccountCards() async {
    final userId = currentUserId;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      if (!_disposed) notifyListeners();

      // Cancel previous subscription
      _cardsSubscription?.cancel();

      _cardsSubscription = _repository.getAccountCards(userId).listen((cards) {
        if (_disposed) return;
        _accountCards = cards;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        if (_disposed) return;
        console('Error in account cards stream: $error', type: DebugType.error);
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      if (_disposed) return;
      console('Error loading account cards: $e', type: DebugType.error);
      _error = 'Failed to load cards. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new account card
  Future<bool> createAccountCard({
    required String name,
    required String accountName,
    required String number,
    required String type,
    required double balance,
    required Color color,
    required IconData icon,
    String? linkedBankAssetId,
  }) async {
    console('DEBUG: Creating account card with user ID: $currentUserId',
        type: DebugType.info);

    if (currentUserId == null) {
      console('DEBUG: User ID is null, cannot create account card',
          type: DebugType.error);
      _error = 'User ID is required';
      notifyListeners();
      return false;
    }

    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newAccountCard = AccountCardModel.create(
        userId: currentUserId!,
        name: name,
        accountName: accountName,
        number: number,
        type: type,
        balance: balance,
        color: color,
        icon: icon,
        linkedBankAssetId: linkedBankAssetId,
      );

      console('DEBUG: Created AccountCardModel with ID: ${newAccountCard.id}',
          type: DebugType.info);

      await _repository.createAccountCard(newAccountCard);
      console('DEBUG: Successfully saved account card to Firestore',
          type: DebugType.info);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      console('DEBUG: Error creating account card: $e', type: DebugType.error);
      _error = 'Failed to create account card: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing account card
  Future<bool> updateAccountCard(AccountCardModel accountCard) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateAccountCard(accountCard);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      console('Error updating account card: $e', type: DebugType.error);
      _error = 'Failed to update account card: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete an account card
  Future<bool> deleteAccountCard(String id) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteAccountCard(id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      console('Error deleting account card: $e', type: DebugType.error);
      _error = 'Failed to delete account card: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Select an account card
  void selectAccountCard(String id) {
    _selectedAccountCard = _accountCards.firstWhere(
      (card) => card.id == id,
      orElse: () => _selectedAccountCard!,
    );
    notifyListeners();
  }

  // Clear selected account card
  void clearSelectedAccountCard() {
    _selectedAccountCard = null;
    notifyListeners();
  }

  // Get account card by ID
  Future<AccountCardModel?> getAccountCardById(String id) async {
    try {
      return await _repository.getAccountCard(id);
    } catch (e) {
      console('Error getting account card: $e', type: DebugType.error);
      _error = 'Failed to get account card: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Public method to reload account cards
  void reloadAccountCards() {
    console('DEBUG: Reloading account cards', type: DebugType.info);
    _loadAccountCards();
  }

  @override
  void dispose() {
    _cardsSubscription?.cancel();
    _disposed = true;
    super.dispose();
  }
}
