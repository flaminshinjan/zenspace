import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: now.weekday - 1 - index));
      return _CalendarDay(
        date: date,
        isSelected: date.day == now.day,
      );
    });

    return Container(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days,
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isSelected;

  const _CalendarDay({
    required this.date,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EE').format(date).substring(0, 2);
    final dayNum = date.day.toString().padLeft(2, '0');

    return Container(
      width: 40,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white10 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white38,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayNum,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 