import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppColors.clay300,
          ),
          const SizedBox(height: 24),
          Text(
            'Calendar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.sidebarText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.sidebarTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
