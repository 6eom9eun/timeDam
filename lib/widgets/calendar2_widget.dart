import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:intl/intl.dart';

class Calendar2 extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const Calendar2({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,

  }) : super(key: key);

  @override
  _Calendar2State createState() => _Calendar2State();
}

class _Calendar2State extends State<Calendar2> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: widget.focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      firstDay: DateTime(2022, 1, 1),
      lastDay: DateTime(2023, 12, 31),
      rowHeight: 50, // 더 높은 행으로 좀 더 공간을 제공합니다.
      daysOfWeekHeight: 30, // 요일 표시 부분의 높이를 늘렸습니다.
      headerVisible: true,
      headerStyle: HeaderStyle(
        titleCentered: true, // 제목을 중앙에 위치시킵니다.
        titleTextStyle: TextStyle(
          color: Colors.black54,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        formatButtonVisible: false, // 달력 형식 변경 버튼을 숨깁니다.
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.redAccent),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.grey[700]),
        weekendTextStyle: TextStyle(color: Colors.redAccent),
        todayDecoration: BoxDecoration(
          color: Color(0xFFF4C54F),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDaySelected(selectedDay);
      },
      onPageChanged: widget.onDaySelected,
      calendarFormat: CalendarFormat.month,
    );
  }
}
