import 'package:fe_chronos/features/chat/services/chat_service.dart';
import 'package:fe_chronos/features/chat/viewmodels/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/auth/presentation/login_screen.dart';

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

        Provider<ChatService>(create: (_) => ChatService()),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) =>
              ChatViewModel(context.read<ChatService>())..loadInitialMessages(),
        ),
      ],
      child: MaterialApp(
        title: 'Chronos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
