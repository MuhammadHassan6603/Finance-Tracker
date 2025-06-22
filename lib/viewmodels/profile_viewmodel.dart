import 'package:finance_tracker/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/profile_repository.dart';
import 'auth_viewmodel.dart';
import 'dart:async';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;
  final AuthViewModel _authViewModel;

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  StreamSubscription? _subscription;

  ProfileViewModel({
    required AuthViewModel authViewModel,
    ProfileRepository? repository,
  })  : _authViewModel = authViewModel,
        _repository = repository ?? ProfileRepository() {
    _init();
  }

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthViewModel get authViewModel => _authViewModel;

  void _init() {
    if (_authViewModel.currentUser != null) {
      _loadProfile();
    }
    _authViewModel.addListener(_authStateChanged);
  }

  void _authStateChanged() {
    if (_authViewModel.currentUser != null) {
      _loadProfile();
    } else {
      _profile = null;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    final user = _authViewModel.currentUser;
    if (user == null || _disposed) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = _repository.getProfile(user).listen(
        (profile) {
          if (_disposed) return;
          _profile = profile ?? _createDefaultProfile(user);
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
      _error = 'Failed to load profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  ProfileModel _createDefaultProfile(UserModel user) {
    return ProfileModel(
      id: user.id,
      email: user.email,
      name: user.name,
      photoUrl: user.photoUrl,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<bool> saveProfile(ProfileModel profile) async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.saveProfile(profile);
      return true;
    } catch (e) {
      _error = 'Failed to save profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(String photoUrl) async {
    if (_disposed || _profile == null) return false;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateProfilePhoto(_profile!.id, photoUrl);
      return true;
    } catch (e) {
      _error = 'Failed to update profile photo: ${e.toString()}';
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
} 