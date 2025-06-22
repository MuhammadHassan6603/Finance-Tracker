import 'package:finance_tracker/core/utils/motion_toast.dart';
import 'package:finance_tracker/generated/l10n.dart';
import 'package:finance_tracker/presentation/views/auth/login_view.dart';
import 'package:finance_tracker/presentation/views/auth/widgets/or_sign_up_line.dart';
import 'package:finance_tracker/presentation/views/auth/widgets/social_button.dart';
import 'package:finance_tracker/widgets/app_header_text.dart';
import 'package:finance_tracker/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/shared_dynamic_icon.dart';
import '../../../core/services/session_manager.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const SignupViewContent(),
    );
  }
}

class SignupViewContent extends StatefulWidget {
  const SignupViewContent({super.key});

  @override
  State<SignupViewContent> createState() => _SignupViewContentState();
}

class _SignupViewContentState extends State<SignupViewContent> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  // Add controllers to manage text input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle sign up with email/password
  Future<void> _handleSignUp(BuildContext context) async {
    if (!_agreedToTerms) {
      ToastUtils.showErrorToast(context,
          title: 'Validation Failed',
          description: 'Please agree to Terms & Conditions');

      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<AuthViewModel>();
      final sessionManager = context.read<SessionManager>();

      viewModel.setName(_nameController.text);
      viewModel.setEmail(_emailController.text);
      viewModel.setPassword(_passwordController.text);

      final success = await viewModel.signUp();

      if (success && mounted) {
        await sessionManager.onAuthenticationSuccess();
        ToastUtils.showSuccessToast(context,
            title: 'Email Sent',
            description: 'Please check your email for the verification link.');
        Navigator.pushReplacementNamed(context, Routes.signIn);
        // No need to navigate, SessionWrapper will handle it
      } else if (mounted) {
        ToastUtils.showErrorToast(context,
            title: 'Failed', description: viewModel.errorMessage);
      }
    }
  }

  // Handle Google sign in
  Future<void> _handleGoogleSignIn(BuildContext context) async {
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
                  AppHeaderText(text: local.createYourAccount),
                  const Gap(30),
                  CustomTextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    hintText: local.name,
                    icon: Icons.person_3_outlined,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return local.pleaseEnterAName;
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
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
                    obscureText: _obscurePassword,
                    icon: Icons.lock_outline,
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
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          local.agreeToTerms,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  CustomButton(
                    onPressed: viewModel.isLoading
                        ? () {}
                        : () => _handleSignUp(context),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            local.signUp,
                            style: const TextStyle(
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
                    onPressed: viewModel.isLoading
                        ? () {}
                        : () => _handleGoogleSignIn(context),
                    icon: 'assets/images/google_icon.png',
                    label: 'Google',
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(text: local.alreadyHaveAnAccount),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginViewContent(),
                                ),
                              );
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
