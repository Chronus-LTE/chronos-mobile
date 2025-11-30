import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/auth/presentation/login_screen.dart';
import 'package:chronus/features/auth/presentation/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.clay100,
              AppColors.clay50,
              AppColors.neutralWhite,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo and Title
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.clay600,
                        AppColors.clay500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.clay300.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    size: 50,
                    color: AppColors.neutralWhite,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to Chronos',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralInk,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Manage your time wisely and\nachieve your goals with ease',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.sidebarTextSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clay700,
                      foregroundColor: AppColors.neutralWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Log In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.clay700,
                      side: const BorderSide(
                        color: AppColors.mainBorder,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Terms
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.sidebarTextSecondary,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(text: 'By continuing, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.clay700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.clay700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
