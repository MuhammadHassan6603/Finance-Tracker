import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../viewmodels/transaction_viewmodel.dart';

class TransactionMonthSelector extends StatefulWidget {
  final DateTime focusedDay;
  final ValueChanged<DateTime> onMonthChanged;

  const TransactionMonthSelector({
    super.key,
    required this.focusedDay,
    required this.onMonthChanged,
  });

  @override
  State<TransactionMonthSelector> createState() =>
      _TransactionMonthSelectorState();
}

class _TransactionMonthSelectorState extends State<TransactionMonthSelector> {
  late DateTime _focusedDay;
  bool _isCalendarVisible = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _handleMonthChange(-1),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _isCalendarVisible = !_isCalendarVisible),
                child: _buildMonthSelector(),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _handleMonthChange(1),
              ),
            ],
          ),
        ),
        if (_isCalendarVisible) _buildCalendar(),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM, yyyy').format(_focusedDay),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onPageChanged: (focusedDay) {
          final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
          setState(() => _focusedDay = firstDay);
          widget.onMonthChanged(firstDay);
          context.read<TransactionViewModel>().setSelectedMonth(firstDay);
        },
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
      ),
    );
  }

  void _handleMonthChange(int monthsToAdd) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + monthsToAdd);
      widget.onMonthChanged(_focusedDay);
    });
  }
}
