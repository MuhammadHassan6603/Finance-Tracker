import 'package:finance_tracker/core/utils/validators.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/auth/widgets/or_sign_up_line.dart';
import 'package:finance_tracker/presentation/views/auth/widgets/social_button.dart';
import 'package:finance_tracker/presentation/views/dashboard/dashboard_view.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/custom_button.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/routes.dart';
import '../../../widgets/shared_dynamic_icon.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import 'forgot_password_screen.dart';
import 'signup_view.dart';
import '../../../core/services/session_manager.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const LoginViewContent(),
    );
  }
}

class LoginViewContent extends StatefulWidget {
  const LoginViewContent({super.key});

  @override
  State<LoginViewContent> createState() => _LoginViewContentState();
}

class _LoginViewContentState extends State<LoginViewContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<AuthViewModel>();
      final sessionManager = context.read<SessionManager>();

      viewModel.setEmail(_emailController.text);
      viewModel.setPassword(_passwordController.text);

      final success = await viewModel.signIn();

      if (success && mounted) {
        await sessionManager.onAuthenticationSuccess();
        Navigator.pushReplacementNamed(context, Routes.dashboard);
        // No need to navigate, SessionWrapper will handle it
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage)),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final viewModel = context.read<AuthViewModel>();
    final sessionManager = context.read<SessionManager>();

    final success = await viewModel.signInWithGoogle();

    if (success && mounted) {
      await sessionManager.onAuthenticationSuccess();
      // No need to navigate, SessionWrapper will handle it
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final local = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(20),
                  Image.asset('assets/icons/app_logo.jpg',
                      width: 100, height: 100),
                  const Gap(30),
                  AppHeaderText(text: local.welcomeBack),
                  const Gap(30),
                  CustomTextField(
                    controller: _emailController,
                    textCapitalization: TextCapitalization.none,
                    hintText: local.emailAddress,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return local.pleaseEnterYourEmail;
                      }
                      if (!Validators.isValidEmail(value!)) {
                        return local.pleaseEnterAValidEmail;
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  CustomTextField(
                    controller: _passwordController,
                    textCapitalization: TextCapitalization.none,
                    hintText: local.password,
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return local.pleaseEnterYourPassword;
                      }
                      if (!Validators.isValidPassword(value!)) {
                        return local.passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ),
                  const Gap(10),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      style:
                          TextButton.styleFrom(minimumSize: const Size(30, 14)),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.forgotScreen);
                      },
                      child: Text(
                        local.forgotPassword,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: viewModel.isLoading ? () {} : _handleEmailLogin,
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const Gap(20),
                  const OrSignUpWithWidget(),
                  const Gap(20),
                  SocialLoginButton(
                    onPressed:
                        viewModel.isLoading ? () {} : _handleGoogleSignIn,
                    icon: 'assets/images/google_icon.png',
                    label: 'Google',
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(text: local.dontHaveAccount),
                        TextSpan(
                          text: local.signUp,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, Routes.signUp);
                            },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
