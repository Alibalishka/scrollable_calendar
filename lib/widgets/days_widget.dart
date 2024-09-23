import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';

class DaysWidget extends StatelessWidget {
  final CleanCalendarController cleanCalendarController;
  final DateTime month;
  final double calendarCrossAxisSpacing;
  final double calendarMainAxisSpacing;
  final Layout? layout;
  final Widget Function(
    BuildContext context,
    DayValues values,
  )? dayBuilder;
  final Color? selectedBackgroundColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColorBetween;
  final Color? disableBackgroundColor;
  final Color? dayDisableColor;
  final double radius;
  final TextStyle? textStyle;
  final bool isMultiSelect;
  final List<DateTime> redDays;
  final Color redDayColor;

  const DaysWidget({
    Key? key,
    required this.month,
    required this.cleanCalendarController,
    required this.calendarCrossAxisSpacing,
    required this.calendarMainAxisSpacing,
    required this.layout,
    required this.dayBuilder,
    required this.selectedBackgroundColor,
    required this.backgroundColor,
    required this.selectedBackgroundColorBetween,
    required this.disableBackgroundColor,
    required this.dayDisableColor,
    required this.radius,
    required this.textStyle,
    required this.isMultiSelect,
    required this.redDays,
    required this.redDayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Start weekday - Days per week - The first weekday of this month
    // 7 - 7 - 1 = -1 = 1
    // 6 - 7 - 1 = -2 = 2

    // What it means? The first weekday does not change, but the start weekday have changed,
    // so in the layout we need to change where the calendar first day is going to start.
    int monthPositionStartDay = (cleanCalendarController.weekdayStart -
            DateTime.daysPerWeek -
            DateTime(month.year, month.month).weekday)
        .abs();
    monthPositionStartDay = monthPositionStartDay > DateTime.daysPerWeek
        ? monthPositionStartDay - DateTime.daysPerWeek
        : monthPositionStartDay;

    final start = monthPositionStartDay == 7 ? 0 : monthPositionStartDay;

    // If the monthPositionStartDay is equal to 7, then in this layout logic will cause a trouble, beacause it will
    // have a line in blank and in this case 7 is the same as 0.

    return GridView.count(
      crossAxisCount: DateTime.daysPerWeek,
      physics: const NeverScrollableScrollPhysics(),
      addRepaintBoundaries: false,
      padding: EdgeInsets.zero,
      crossAxisSpacing: calendarCrossAxisSpacing,
      mainAxisSpacing: calendarMainAxisSpacing,
      shrinkWrap: true,
      children: List.generate(
          DateTime(month.year, month.month + 1, 0).day + start, (index) {
        if (index < start) return const SizedBox.shrink();
        final day = DateTime(month.year, month.month, (index + 1 - start));
        final text = (index + 1 - start).toString();

        bool isSelected = false;

        if (isMultiSelect) {
          cleanCalendarController.multiSelectedDate.contains(day)
              ? isSelected = true
              : isSelected = false;
        } else {
          if (cleanCalendarController.rangeMinDate != null) {
            if (cleanCalendarController.rangeMinDate != null &&
                cleanCalendarController.rangeMaxDate != null) {
              isSelected = day.isSameDayOrAfter(
                      cleanCalendarController.rangeMinDate!) &&
                  day.isSameDayOrBefore(cleanCalendarController.rangeMaxDate!);
            } else {
              isSelected =
                  day.isAtSameMomentAs(cleanCalendarController.rangeMinDate!);
            }
          }
        }

        Widget widget;
        final dayValues = DayValues(
          day: day,
          // isFirstDayOfWeek: day.weekday == cleanCalendarController.weekdayStart,
          isFirstDayOfWeek: day.weekday == cleanCalendarController.weekdayStart,
          isSaturdayDayOfWeek: day.weekday == 6,
          isLastDayOfWeek: day.weekday == cleanCalendarController.weekdayEnd,
          isSelected: isSelected,
          maxDate: cleanCalendarController.maxDate,
          minDate: cleanCalendarController.minDate,
          text: text,
          selectedMaxDate: cleanCalendarController.rangeMaxDate,
          selectedMinDate: cleanCalendarController.rangeMinDate,
          isRed: redDays.contains(day),
        );

        if (dayBuilder != null) {
          widget = dayBuilder!(context, dayValues);
        } else {
          widget = <Layout, Widget Function()>{
            // Layout.DEFAULT: () => _pattern(context, dayValues),
            Layout.BEAUTY: () => _beauty(context, dayValues),
          }[layout]!();
        }

        return GestureDetector(
          onTap: () {
            if (isMultiSelect) {
              cleanCalendarController.onDaysClick(day);
            } else {
              if (day.isBefore(cleanCalendarController.minDate) &&
                  !day.isSameDay(cleanCalendarController.minDate)) {
                if (cleanCalendarController.onPreviousMinDateTapped != null) {
                  cleanCalendarController.onPreviousMinDateTapped!(day);
                }
              } else if (day.isAfter(cleanCalendarController.maxDate)) {
                if (cleanCalendarController.onAfterMaxDateTapped != null) {
                  cleanCalendarController.onAfterMaxDateTapped!(day);
                }
              } else {
                if (!cleanCalendarController.readOnly) {
                  cleanCalendarController.onDayClick(day);
                }
              }
            }
          },
          child: widget,
        );
      }),
    );
  }

  // Widget _pattern(BuildContext context, DayValues values) {
  //   Color bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
  //   TextStyle txtStyle =
  //       (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
  //     color: backgroundColor != null
  //         ? backgroundColor!.computeLuminance() > .5
  //             ? Colors.black
  //             : Colors.white
  //         : Theme.of(context).colorScheme.onSurface,
  //   );

  //   if (values.isSelected) {
  //     if ((values.selectedMinDate != null &&
  //             values.day.isSameDay(values.selectedMinDate!)) ||
  //         (values.selectedMaxDate != null &&
  //             values.day.isSameDay(values.selectedMaxDate!))) {
  //       bgColor =
  //           selectedBackgroundColor ?? Theme.of(context).colorScheme.primary;
  //       txtStyle =
  //           (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
  //         color: selectedBackgroundColor != null
  //             ? selectedBackgroundColor!.computeLuminance() > .5
  //                 ? Colors.black
  //                 : Colors.white
  //             : Theme.of(context).colorScheme.onPrimary,
  //       );
  //     } else {
  //       bgColor = selectedBackgroundColorBetween ??
  //           Theme.of(context).colorScheme.primary.withOpacity(.3);
  //       txtStyle =
  //           (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
  //         color: selectedBackgroundColor != null &&
  //                 selectedBackgroundColor == selectedBackgroundColorBetween
  //             ? selectedBackgroundColor!.computeLuminance() > .5
  //                 ? Colors.black
  //                 : Colors.white
  //             : selectedBackgroundColor ??
  //                 Theme.of(context).colorScheme.primary,
  //       );
  //     }
  //   } else if (values.day.isSameDay(values.minDate)) {
  //     bgColor = Colors.transparent;
  //     txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
  //       color: selectedBackgroundColor ?? Theme.of(context).colorScheme.primary,
  //     );
  //   } else if (values.day.isBefore(values.minDate) ||
  //       values.day.isAfter(values.maxDate)) {
  //     bgColor = disableBackgroundColor ??
  //         Theme.of(context).colorScheme.surface.withOpacity(.4);
  //     txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
  //       color: dayDisableColor ??
  //           Theme.of(context).colorScheme.onSurface.withOpacity(.5),
  //       decoration: TextDecoration.lineThrough,
  //     );
  //   }

  //   return Container(
  //     alignment: Alignment.center,
  //     decoration: BoxDecoration(
  //       color: bgColor,
  //       borderRadius: BorderRadius.circular(radius),
  //       border: values.day.isSameDay(values.minDate)
  //           ? Border.all(
  //               color: selectedBackgroundColor ??
  //                   Theme.of(context).colorScheme.primary,
  //               width: 2,
  //             )
  //           : null,
  //     ),
  //     child: Text(
  //       values.text,
  //       textAlign: TextAlign.center,
  //       style: txtStyle,
  //     ),
  //   );
  // }

  Widget _beauty(BuildContext context, DayValues values) {
    BorderRadiusGeometry? borderRadius;
    BorderRadiusGeometry? borderRadiusbgSecond;
    Gradient? boxGradient;
    Color bgColor = Colors.transparent;
    Color colorbgSecond = Colors.transparent;
    bool isRedDay = values.isRed;
    TextStyle txtStyle =
        (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
      color: backgroundColor != null
          ? backgroundColor!.computeLuminance() > .5
              ? Colors.black
              : Colors.white
          : Theme.of(context).colorScheme.onSurface,
      fontWeight: values.isSaturdayDayOfWeek || values.isLastDayOfWeek
          ? FontWeight.bold
          : null,
    );

    if (values.isSelected) {
      // if (values.isFirstDayOfWeek) {
      //   boxGradient = LinearGradient(
      //     colors: [
      //       selectedBackgroundColorBetween ??
      //           Theme.of(context).colorScheme.primary,
      //       selectedBackgroundColorBetween?.withOpacity(0.0) ??
      //           Theme.of(context).colorScheme.primary.withOpacity(0.0)
      //     ],
      //     begin: Alignment.centerRight,
      //     end: Alignment.centerLeft,
      //   );
      // } else if (values.isLastDayOfWeek) {
      //   boxGradient = LinearGradient(
      //     colors: [
      //       selectedBackgroundColorBetween ??
      //           Theme.of(context).colorScheme.primary,
      //       selectedBackgroundColorBetween?.withOpacity(0.0) ??
      //           Theme.of(context).colorScheme.primary.withOpacity(0.0)
      //     ],
      //     begin: Alignment.centerLeft,
      //     end: Alignment.centerRight,
      //   );
      // }

      if ((values.selectedMinDate != null &&
              values.day.isSameDay(values.selectedMinDate!)) ||
          (values.selectedMaxDate != null &&
              values.day.isSameDay(values.selectedMaxDate!))) {
        bgColor =
            selectedBackgroundColor ?? Theme.of(context).colorScheme.primary;
        colorbgSecond = selectedBackgroundColorBetween ??
            Theme.of(context).colorScheme.primary.withOpacity(.3);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
          color: selectedBackgroundColor != null
              ? selectedBackgroundColor!.computeLuminance() > .5
                  ? Colors.black
                  : Colors.white
              : Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        );
        if (values.selectedMinDate == values.selectedMaxDate) {
          borderRadius = BorderRadius.circular(radius);
        } else if (values.selectedMinDate != null &&
            values.day.isSameDay(values.selectedMinDate!)) {
          borderRadius = BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
          borderRadiusbgSecond = BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
        } else if (values.selectedMaxDate != null &&
            values.day.isSameDay(values.selectedMaxDate!)) {
          borderRadius = BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
          borderRadiusbgSecond = BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
        }
      } else {
        if (isMultiSelect) {
          borderRadius = BorderRadius.all(Radius.circular(radius));
          colorbgSecond = Colors.transparent;
          bgColor =
              selectedBackgroundColor ?? Theme.of(context).colorScheme.primary;
          txtStyle = txtStyle =
              (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
            color: selectedBackgroundColor != null
                ? selectedBackgroundColor!.computeLuminance() > .5
                    ? Colors.black
                    : Colors.white
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          );
        } else {
          if (values.isLastDayOfWeek ||
              (values.isFirstDayOfWeek &&
                  values.day.weekday == DateTime.monday)) {
            bgColor = selectedBackgroundColorBetween ??
                Theme.of(context).colorScheme.primary.withOpacity(.3);
          } else {
            bgColor = selectedBackgroundColorBetween ??
                Theme.of(context).colorScheme.primary.withOpacity(.3);
          }
          if (values.isFirstDayOfWeek) {
            boxGradient = LinearGradient(
              colors: [
                selectedBackgroundColorBetween ??
                    Theme.of(context).colorScheme.primary,
                selectedBackgroundColorBetween?.withOpacity(0.0) ??
                    Theme.of(context).colorScheme.primary.withOpacity(0.0)
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            );
          } else if (values.isLastDayOfWeek) {
            boxGradient = LinearGradient(
              colors: [
                selectedBackgroundColorBetween ??
                    Theme.of(context).colorScheme.primary,
                selectedBackgroundColorBetween?.withOpacity(0.0) ??
                    Theme.of(context).colorScheme.primary.withOpacity(0.0)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            );
          }
          txtStyle =
              (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
            color: selectedBackgroundColor ??
                Theme.of(context).colorScheme.primary,
            fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
                ? FontWeight.bold
                : null,
          );
        }
      }
    } else if (values.day.isSameDay(values.minDate)) {
    } else if (values.day.isBefore(values.minDate) ||
        values.day.isAfter(values.maxDate)) {
      isRedDay = false;
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: dayDisableColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.4),
        decoration: TextDecoration.lineThrough,
        fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
            ? FontWeight.normal
            : null,
      );
    }

    return Column(
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: colorbgSecond,
            borderRadius: borderRadiusbgSecond,
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
              gradient: boxGradient,
            ),
            child: Text(
              values.text,
              textAlign: TextAlign.center,
              style: txtStyle,
            ),
          ),
        ),
        isRedDay ? const SizedBox(height: 5) : const SizedBox.shrink(),
        isRedDay
            ? Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: redDayColor,
                  shape: BoxShape.circle,
                ),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
