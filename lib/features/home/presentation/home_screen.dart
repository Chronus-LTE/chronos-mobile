import 'package:fe_chronos/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chronos Assistant'), centerTitle: true),
      body: ChatScreen(), // khung gọi body = ChatScreen
    );
  }
}
