import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/onboarding/presentation/onboarding_screen.dart';
import 'package:chronus/core/layout/main_layout.dart';
import 'package:chronus/features/auth/viewmodels/auth_view_model.dart';
import 'package:chronus/features/onboarding/presentation/welcome_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final authVm = context.read<AuthViewModel>();

    // Check login status and first time status concurrently
    final results = await Future.wait([
      authVm.checkLoginStatus(),
      authVm.checkFirstTime(),
    ]);

    final isLoggedIn = results[0];
    final isFirstTime = results[1];

    if (!mounted) return;

    Widget nextScreen;
    if (isLoggedIn) {
      nextScreen = const MainLayout();
    } else if (isFirstTime) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const WelcomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.clay100,
              AppColors.clay50,
              AppColors.neutralWhite,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.clay600,
                          AppColors.clay500,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.clay300.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      size: 60,
                      color: AppColors.neutralWhite,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  const Text(
                    'Chronos',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutralInk,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Time, Organized',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.sidebarTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
