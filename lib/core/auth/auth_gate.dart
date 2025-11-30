import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronus/features/auth/viewmodels/auth_view_model.dart';
import 'package:chronus/features/onboarding/presentation/splash_screen.dart';
import 'package:chronus/core/layout/main_layout.dart';

/// Auth Gate - Checks authentication status and routes accordingly
/// - If logged in: Go to MainLayout
/// - If not logged in: Go to SplashScreen (which leads to onboarding/login)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    if (authVm.isLoggedIn) {
      return const MainLayout();
    }

    return const SplashScreen();
  }
}
