import 'package:finance_tracker/presentation/views/auth/forgot_password_screen.dart';
import 'package:finance_tracker/presentation/views/auth/login_view.dart';
import 'package:finance_tracker/presentation/views/auth/signup_view.dart';
import 'package:finance_tracker/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/views/on_boardings/currency_picker_screen.dart';
import '../../presentation/views/on_boardings/landing_screens.dart';
import '../../presentation/views/session_wrapper.dart';
import '../../viewmodels/auth_viewmodel.dart';

class Routes {
  static const String sessionWrapper = "/";
  static const String intro = "/intro";
  static const String location = "/location";
  static const String signIn = "/sign-in";
  static const String signUp = "/sign-up";
  static const String forgotScreen = "forgot-screen";
  static const String profileCreation = "/profile_creation";
  static const String passwordScreen = "/password_screen";
  static const String editPasswordScreen = "/password_screen";
  static const String currencyPicker = "/currency-picker";
  static const String resetEmail = "/reset-email";
  static const String locationListing = "/location-listing";
  static const String searchLocation = "/search-location";
  static const String dashboard = "/dashboard";
}

final navKey = GlobalKey<NavigatorState>();

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.signIn:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => AuthViewModel(),
            child: const LoginView(),
          ),
        );
      case Routes.signUp:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => AuthViewModel(),
            child: const SignupView(),
          ),
        );
      case Routes.currencyPicker:
        return MaterialPageRoute(
          builder: (_) => const CurrencyPickerScreen(),
        );
      case Routes.intro:
        return MaterialPageRoute(
          builder: (_) => const LandingScreens(),
        );
      case Routes.sessionWrapper:
        return MaterialPageRoute(
          builder: (_) => const SessionWrapper(),
        );
      case Routes.forgotScreen:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case Routes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardView(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('No Route Found!'),
            ),
            body: const Center(
              child: Text('No Route Found!'),
            ),
          ),
        );
    }
  }
}
