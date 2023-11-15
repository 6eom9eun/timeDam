import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
      focusedDay: widget.focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      firstDay: DateTime(2022, 1, 1),
      lastDay: DateTime(2023, 12, 31),
      rowHeight: 40,
      daysOfWeekHeight: 20,
      headerVisible: true,
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black54,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        formatButtonVisible: false,
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
        markerDecoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDaySelected(selectedDay);
      },
      onPageChanged: widget.onDaySelected,
      eventLoader: widget.eventLoader, // 이벤트 로더 설정
      calendarFormat: CalendarFormat.month,
    );
  }
}
