import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final calendarController = CleanCalendarController(
    minDate: DateTime.now(),
    maxDate: DateTime.now().add(const Duration(days: 365)),
    onRangeSelected: (firstDate, secondDate) {},
    onDayTapped: (date) {},
    // readOnly: true,
    onPreviousMinDateTapped: (date) {},
    onAfterMaxDateTapped: (date) {},
    weekdayStart: DateTime.monday,
    // initialFocusDate: DateTime(2023, 5),
    // initialDateSelected: DateTime(2022, 3, 15),
    // endDateSelected: DateTime(2022, 3, 20),
  );

  @override
  Widget build(BuildContext context) {
    List<DateTime> redDates = [
      DateFormat("dd.MM.yyyy").parse('21.05.2024'),
      DateFormat("dd.MM.yyyy").parse('22.05.2024'),
      DateFormat("dd.MM.yyyy").parse('23.05.2024'),
      DateFormat("dd.MM.yyyy").parse('24.05.2024'),
      DateFormat("dd.MM.yyyy").parse('25.05.2024'),
      DateFormat("dd.MM.yyyy").parse('26.05.2024'),
    ];
    return MaterialApp(
      title: 'Scrollable Clean Calendar',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFF3F51B5),
          primaryContainer: Color(0xFF002984),
          secondary: Color(0xFFD32F2F),
          secondaryContainer: Color(0xFF9A0007),
          surface: Color(0xFFDEE2E6),
          background: Color(0xFFF8F9FA),
          error: Color(0xFF96031A),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () async {
              await HomeBottomSheet.buildCalendarBottomSheet(
                context: context,
                calendarController: calendarController,
                dateList: redDates,
              );
            },
            child: const Text(
              'Scrollable Clean Calendar',
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                calendarController.clearSelectedDates();
              },
              icon: const Icon(Icons.clear),
            )
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: const Icon(Icons.arrow_downward),
        //   onPressed: () {
        //     calendarController.jumpToMonth(date: DateTime(2022, 8));
        //   },
        // ),
        body: ScrollableCleanCalendar(
          calendarController: calendarController,
          calendarCrossAxisSpacing: 0,
          calendarMainAxisSpacing: 0,
          isMultiSelect: false,
          redDays: redDates,
          daySelectedBackgroundColor: Color(0xFF3E4157),
          daySelectedBackgroundColorBetween: Color(0xFFE7E7E7),
          dayDisableColor: Color(0xFF9198AF),
        ),
      ),
    );
  }
}

class HomeBottomSheet {
  static Future<dynamic> buildCalendarBottomSheet({
    required BuildContext context,
    required CleanCalendarController calendarController,
    required List<DateTime>? dateList,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          calendarController.addListener(() => setState(() {}));
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.2,
            maxChildSize: 0.7,
            expand: false,
            builder: (_, controller) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 24,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => {},
                            child: Text(
                              'Назад',
                              textAlign: TextAlign.end,
                              // style: AppTextStyles.buttonText
                              //     .copyWith(color: AppColors.secondaryColor400),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Выберите даты',
                            // style: AppTextStyles.heading7
                            //     .copyWith(color: AppColors.color3E4157),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ScrollableCleanCalendar(
                        calendarController: calendarController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        calendarCrossAxisSpacing: 12,
                        isMultiSelect: false,
                        spaceBetweenCalendars: 16,
                        redDays: dateList,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1.6),
                  const SizedBox(height: 2.4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
