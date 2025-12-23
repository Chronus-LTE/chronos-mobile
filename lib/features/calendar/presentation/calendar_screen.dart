import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/calendar/models/calendar_event.dart';
import 'package:chronus/features/calendar/viewmodels/calendar_view_model.dart';
import 'package:chronus/features/calendar/presentation/widgets/event_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<CalendarViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading && viewModel.allEvents.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.clay600,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: viewModel.refreshEvents,
                  color: AppColors.clay600,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildCalendarGrid(context),
                          const SizedBox(height: 24),
                          _buildEventsList(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(context),
        backgroundColor: AppColors.clay600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        final monthYear = DateFormat('MMMM yyyy').format(viewModel.focusedMonth);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            border: Border(
              bottom: BorderSide(color: AppColors.mainBorder, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => viewModel.changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                  color: AppColors.clay600,
                ),
                Expanded(
                  child: Text(
                    monthYear,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sidebarText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => viewModel.changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                  color: AppColors.clay600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        final firstDayOfMonth = DateTime(
          viewModel.focusedMonth.year,
          viewModel.focusedMonth.month,
          1,
        );
        final lastDayOfMonth = DateTime(
          viewModel.focusedMonth.year,
          viewModel.focusedMonth.month + 1,
          0,
        );

        final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
        final daysInMonth = lastDayOfMonth.day;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mainBorder),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Weekday headers
              Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sidebarTextSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Calendar days
              ...List.generate(6, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const Expanded(child: SizedBox());
                      }

                      final date = DateTime(
                        viewModel.focusedMonth.year,
                        viewModel.focusedMonth.month,
                        dayNumber,
                      );

                      final isSelected = viewModel.selectedDate.year == date.year &&
                          viewModel.selectedDate.month == date.month &&
                          viewModel.selectedDate.day == date.day;

                      final isToday = DateTime.now().year == date.year &&
                          DateTime.now().month == date.month &&
                          DateTime.now().day == date.day;

                      final hasEvents = viewModel.hasEventsOnDate(date);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => viewModel.selectDate(date),
                          child: Container(
                            height: 44,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.clay600
                                  : isToday
                                      ? AppColors.clay100
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday && !isSelected
                                  ? Border.all(color: AppColors.clay400, width: 1.5)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    '$dayNumber',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.sidebarText,
                                    ),
                                  ),
                                ),
                                if (hasEvents && !isSelected)
                                  Positioned(
                                    bottom: 4,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.clay600,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return Consumer<CalendarViewModel>(
      builder: (context, viewModel, _) {
        final events = viewModel.selectedDateEvents;
        final dateStr = DateFormat('EEEE, MMMM d').format(viewModel.selectedDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.sidebarText,
              ),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.contentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 48,
                        color: AppColors.clay300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No events scheduled',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.sidebarTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...events.map((event) => _buildEventCard(context, event, viewModel)),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, CalendarEvent event, CalendarViewModel viewModel) {
    final timeRange = '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}';
    final color = _parseColor(event.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDialog(context, event: event),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sidebarText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeRange,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.sidebarTextSecondary,
                        ),
                      ),
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.sidebarTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showDeleteConfirmation(context, event.id, viewModel);
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.sidebarTextSecondary,
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDialog(BuildContext context, {CalendarEvent? event}) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(event: event),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String eventId, CalendarViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final success = await viewModel.deleteEvent(eventId);

              // Close loading dialog
              if (context.mounted) Navigator.pop(context);

              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.error ?? 'Failed to delete event'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.clay600;
    }
  }
}
