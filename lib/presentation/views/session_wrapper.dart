import 'package:finance_tracker/core/services/session_manager.dart';
import 'package:finance_tracker/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'on_boardings/landing_screens.dart';
import 'on_boardings/currency_picker_screen.dart';
import 'auth/login_view.dart';

class SessionWrapper extends StatelessWidget {
  const SessionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, sessionManager, _) {
        // First check if user has seen onboarding
        if (!sessionManager.hasSeenOnboarding) {
          return const LandingScreens();
        }

        // Then check if user has selected currency
        if (!sessionManager.hasSelectedCurrency) {
          return const CurrencyPickerScreen();
        }

        // Finally check if user is authenticated
        if (!sessionManager.isAuthenticated) {
          return const LoginView();
        }

        // If all conditions are met, show home screen
        return const DashboardView();
      },
    );
  }
}
