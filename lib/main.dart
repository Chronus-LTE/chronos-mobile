import 'package:chronus/features/chat/services/chat_service.dart';
import 'package:chronus/features/chat/viewmodels/chat_view_model.dart';
import 'package:chronus/features/onboarding/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/core/services/api_client.dart';
import 'package:chronus/features/auth/services/auth_service.dart';
import 'package:chronus/features/auth/viewmodels/auth_view_model.dart';
import 'package:chronus/features/calendar/services/calendar_service.dart';
import 'package:chronus/features/calendar/viewmodels/calendar_view_model.dart';
import 'package:chronus/features/email/services/email_service.dart';
import 'package:chronus/features/email/viewmodels/email_view_model.dart';

void main() {
  runApp(const ChronosApp());
}

class ChronosApp extends StatelessWidget {
  const ChronosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),

        Provider<ApiClient>(
          create: (context) => ApiClient(context.read<AuthService>()),
        ),

        Provider<ChatService>(create: (_) => ChatService()),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) =>
              ChatViewModel(context.read<ChatService>())..loadInitialMessages(),
        ),

        Provider<CalendarService>(
          create: (context) => CalendarService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<CalendarViewModel>(
          create: (context) => CalendarViewModel(context.read<CalendarService>()),
        ),

        Provider<EmailService>(
          create: (context) => EmailService(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<EmailViewModel>(
          create: (context) => EmailViewModel(context.read<EmailService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Chronus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.clay600,
          scaffoldBackgroundColor: AppColors.neutralWhite,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.clay600,
            primary: AppColors.clay600,
            surface: AppColors.neutralWhite,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
