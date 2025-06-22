import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/core/utils/validators.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/auth/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/shared_dynamic_icon.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<AuthViewModel>();

      viewModel.setResetEmail(_emailController.text);
      final success = await viewModel.sendPasswordResetEmail();

      if (success && mounted) {
        setState(() {
          _isEmailSent = true;
        });
        ToastUtils.showSuccessToast(context,
            title: 'Sent',
            description: 'Password reset email sent. Please check your inbox.');
      } else if (mounted) {
        ToastUtils.showErrorToast(context,
            title: 'Error', description: viewModel.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final local = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/icons/app_logo.jpg',
                    width: 100, height: 100),
                const SizedBox(height: 30),
                Text(
                  local.forgotPassword,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  local.pleaseEnterYourEmail,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: local.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return local.pleaseEnterTheEmail;
                    }
                    if (!Validators.isValidEmail(value!)) {
                      return local.pleaseEnterAValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 150),
                if (_isEmailSent)
                  Text(
                    local.resetLinkSent,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.green,
                        ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: viewModel.isLoading ? () {} : _handleResetPassword,
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          local.sendResetLink,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                if (_isEmailSent)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(local.backToLogin),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
