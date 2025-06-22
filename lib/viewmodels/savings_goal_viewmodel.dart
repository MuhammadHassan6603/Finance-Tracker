import 'package:flutter/foundation.dart';
import '../data/models/savings_goal_model.dart';
import '../data/repositories/savings_goal_repository.dart';
import 'auth_viewmodel.dart';
import 'dart:async';

class SavingsGoalViewModel extends ChangeNotifier {
  final SavingsGoalRepository _repository;
  final AuthViewModel _authViewModel;

  List<SavingsGoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription<List<SavingsGoalModel>>? _subscription;

  SavingsGoalViewModel({
    required AuthViewModel authViewModel,
    SavingsGoalRepository? repository,
  })  : _authViewModel = authViewModel,
        _repository = repository ?? SavingsGoalRepository() {
    _init();
  }

  List<SavingsGoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalSaved => _goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  double get totalTarget => _goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  double get overallProgress => totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;
  
  List<SavingsGoalModel> get activeGoals => 
      _goals.where((goal) => !goal.isCompleted).toList();
  
  List<SavingsGoalModel> get completedGoals => 
      _goals.where((goal) => goal.isCompleted).toList();

  AuthViewModel get authViewModel => _authViewModel;

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadGoals();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadGoals();
    } else {
      _goals = [];
      notifyListeners();
    }
  }

  Future<void> _loadGoals() async {
    final userId = _authViewModel.currentUser?.id;
    if (userId == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = _repository.getSavingsGoals(userId).listen(
        (goals) {
          if (_disposed) return;
          _goals = goals;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          if (_disposed) return;
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (_disposed) return;
      _error = 'Failed to load savings goals';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSavingsGoal(SavingsGoalModel goal) async {
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

      await _repository.addSavingsGoal(goal);
      return true;
    } catch (e) {
      _error = 'Failed to create savings goal: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> updateSavingsGoal(SavingsGoalModel goal) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateSavingsGoal(goal);
      return true;
    } catch (e) {
      _error = 'Failed to update savings goal: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> deleteSavingsGoal(String goalId) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Find the goal before deleting
      final goalToDelete = _goals.firstWhere((goal) => goal.id == goalId);
      
      await _repository.deleteSavingsGoal(goalId);
      
      // Update local state
      _goals.removeWhere((goal) => goal.id == goalId);
      
      // Update totals
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Failed to delete savings goal: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> addContribution(String goalId, double amount) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addContribution(goalId, amount);
      return true;
    } catch (e) {
      _error = 'Failed to add contribution: ${e.toString()}';
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

  bool hasGoal(String goalId) {
    return _goals.any((goal) => goal.id == goalId);
  }
} 