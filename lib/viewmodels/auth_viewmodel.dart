import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../core/utils/validators.dart';
import '../data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  // Form fields
  String _email = '';
  String _password = '';
  String _name = '';
  String _errorMessage = '';
  bool _isLoading = false;

  // Additional state for forgot password
  bool _isResetEmailSent = false;
  String _resetEmail = '';

  // Add new state variables
  bool _isEmailVerificationSent = false;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Getters
  String get email => _email;
  String get password => _password;
  String get name => _name;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authRepository.isAuthenticated;
  UserModel? get currentUser => _authRepository.currentUser;

  // Additional getters
  bool get isResetEmailSent => _isResetEmailSent;
  String get resetEmail => _resetEmail;
  bool get isEmailVerificationSent => _isEmailVerificationSent;

  // Setters
  void setEmail(String email) {
    _email = email.trim();
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password.trim();
    notifyListeners();
  }

  void setName(String name) {
    _name = name.trim();
    notifyListeners();
  }

  void setResetEmail(String email) {
    _resetEmail = email.trim();
    notifyListeners();
  }

  // Validation
  bool validateInputs({bool isSignUp = false}) {
    if (!Validators.isValidEmail(_email)) {
      _errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    if (!Validators.isValidPassword(_password)) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }
    if (isSignUp && _name.isEmpty) {
      _errorMessage = 'Please enter your name';
      notifyListeners();
      return false;
    }
    return true;
  }

  // Validate reset email
  bool validateResetEmail() {
    if (!Validators.isValidEmail(_resetEmail)) {
      _errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    return true;
  }

  // Sign In with Email
  Future<bool> signIn() async {
    if (!validateInputs()) return false;

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _authRepository.signInWithEmail(_email, _password);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign Up with Email
  Future<bool> signUp() async {
    if (!validateInputs(isSignUp: true)) return false;

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _authRepository.signUpWithEmail(_email, _password, _name);
      
      _isLoading = false;
      _isEmailVerificationSent = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _authRepository.signInWithGoogle();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      notifyListeners();
    } catch (e) {
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
    }
  }

  // Forgot Password
  Future<bool> sendPasswordResetEmail() async {
    if (!validateResetEmail()) return false;

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _authRepository.sendPasswordResetEmail(_resetEmail);
      
      _isLoading = false;
      _isResetEmailSent = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Optional: Verify reset code
  Future<bool> verifyPasswordResetCode(String code) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final isValid = await _authRepository.verifyPasswordResetCode(code);
      
      _isLoading = false;
      notifyListeners();
      return isValid;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Optional: Confirm password reset
  Future<bool> confirmPasswordReset(String code, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _authRepository.confirmPasswordReset(code, newPassword);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _authRepository.sendEmailVerification();
      
      _isLoading = false;
      _isEmailVerificationSent = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      await _authRepository.reloadUser();
      return _authRepository.isEmailVerified;
    } catch (e) {
      _errorMessage = _getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Helper method to convert Firebase errors to readable messages
  String _getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password provided';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'The password provided is too weak';
        case 'invalid-action-code':
          return 'The reset code is invalid or has expired';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'expired-action-code':
          return 'The reset code has expired';
        case 'email-not-verified':
          return 'Please verify your email before signing in';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        default:
          return error.message ?? 'An unknown error occurred';
      }
    }
    return error.toString();
  }

  // Clear form
  void clearForm() {
    _email = '';
    _password = '';
    _name = '';
    _resetEmail = '';
    _errorMessage = '';
    _isResetEmailSent = false;
    _isEmailVerificationSent = false;
    notifyListeners();
  }
}
