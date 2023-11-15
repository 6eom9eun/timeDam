import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:memo_re/utils/vars.dart';

class Calendar2 extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final List<dynamic> Function(DateTime) eventLoader; // 이벤트 로더 함수

  const Calendar2({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader, // 이벤트 로더 추가
  }) : super(key: key);

  @override
  _Calendar2State createState() => _Calendar2State();
}

class _Calendar2State extends State<Calendar2> {
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: widget.focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      firstDay: DateTime(2022, 1, 1),
      lastDay: DateTime(2023, 12, 31),
      rowHeight: 70, // 행의 높이를 더 크게 설정
      daysOfWeekHeight: 30, // 요일 행의 높이를 더 크게 설정
      headerVisible: true,
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        formatButtonVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.red),
        weekdayStyle: TextStyle(color: Colors.black),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: TextStyle(color: Colors.black),
        weekendTextStyle: TextStyle(color: Colors.red),
        todayDecoration: BoxDecoration(
          color: Color(0xFFE0E0E0),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primaryColor(),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDaySelected(selectedDay);
      },
      onPageChanged: widget.onDaySelected,
      eventLoader: widget.eventLoader,
      calendarFormat: CalendarFormat.month,
    );
  }
}
