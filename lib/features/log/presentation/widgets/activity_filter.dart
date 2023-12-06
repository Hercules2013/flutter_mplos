import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clean_calendar/clean_calendar.dart';

import 'package:mplos_chat/features/log/presentation/providers/log_state_provider.dart';
import 'package:mplos_chat/shared/domain/models/log/software_model.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

class ActivityFilter extends ConsumerStatefulWidget {
  const ActivityFilter({super.key});

  @override
  ConsumerState<ActivityFilter> createState() => _ActivityFilterState();
}

class _ActivityFilterState extends ConsumerState<ActivityFilter> {
  String curFilter = "All Results";
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    const filterOptions = [
      "All Results",
      "Not Work Related Apps",
      "Approved Apps",
      "Rejected Apps",
      "Waiting Approval"
    ];

    return Container(
        decoration: const BoxDecoration(
            border:
                Border(right: BorderSide(color: Colors.black12, width: 1.0))),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350, minWidth: 350),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 36, right: 36),
                  child: Text("Activity Log",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal))),
              const Divider(
                color: AppColors.extraLightGrey,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: CleanCalendar(
                      enableDenseViewForDates: true,
                      enableDenseSplashForDates: true,
                      leadingTrailingDatesProperties: DatesProperties(
                          // To disable taps on leading and trailing dates.
                          // disable: true,

                          // To hide leading and trailing dates.
                          // hide: true,
                          datesDecoration: DatesDecoration(
                              datesBorderRadius: 1000,
                              datesBackgroundColor: Colors.transparent,
                              datesBorderColor: Colors.transparent,
                              datesTextColor: Colors.black38,
                              datesTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w400))),
                      onSelectedDates: handleSelectDate,
                      selectedDates: selectedDates,
                      dateSelectionMode:
                          DatePickerSelectionMode.singleOrMultiple,
                      datePickerCalendarView: DatePickerCalendarView.monthView,
                      headerProperties: HeaderProperties(
                          monthYearDecoration: MonthYearDecoration(
                              monthYearTextColor: Colors.black,
                              monthYearTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  )),
                          navigatorDecoration: NavigatorDecoration(
                              navigatorResetButtonIcon: const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.primary),
                              navigateLeftButtonIcon: const Icon(
                                Icons.navigate_before,
                                color: AppColors.primary,
                              ),
                              navigateRightButtonIcon: const Icon(
                                Icons.navigate_next,
                                color: AppColors.primary,
                              ))),
                      weekdaysProperties: WeekdaysProperties(
                          generalWeekdaysDecoration: WeekdaysDecoration(
                              weekdayTextColor: Colors.black54,
                              weekdayTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w400))),
                      generalDatesProperties: DatesProperties(
                        datesDecoration: DatesDecoration(
                            datesBorderRadius: 1000,
                            datesBackgroundColor: Colors.transparent,
                            datesBorderColor: Colors.transparent,
                            datesTextColor: Colors.black,
                            datesTextStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      currentDateProperties: DatesProperties(
                          datesDecoration: DatesDecoration(
                              datesBorderRadius: 1000,
                              datesBackgroundColor: Colors.transparent,
                              datesBorderColor: AppColors.primary,
                              datesTextColor: AppColors.primary,
                              datesTextStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600))),
                      selectedDatesProperties: DatesProperties(
                          datesDecoration:
                              DatesDecoration(datesBorderRadius: 1000, datesBackgroundColor: AppColors.primary, datesTextColor: AppColors.white)),
                      weekdaysSymbol: const Weekdays(monday: 'MON', tuesday: 'TUE', wednesday: 'WED', thursday: 'THU', friday: 'FRI', saturday: 'SAT', sunday: 'SUN'))),
              const Divider(
                color: AppColors.extraLightGrey,
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 36, right: 36, top: 6, bottom: 6),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: filterOptions
                          .map((option) => Container(
                                decoration: BoxDecoration(
                                    color: curFilter == option
                                        ? const Color(0xffE8F7FB)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.only(bottom: 4),
                                child: TextButton(
                                  onPressed: () {
                                    applyFilter(option);
                                  },
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(
                                          top: 18,
                                          bottom: 18,
                                          left: 12,
                                          right: 12)),
                                  child: Text(option,
                                      style: curFilter == option
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600)
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  color:
                                                      const Color(0xff828282),
                                                  fontWeight: FontWeight.w400)),
                                ),
                              ))
                          .toList()))
            ])));
  }

  void applyFilter(filter) {
    SoftwareConcreteState filterOption = SoftwareConcreteState.all;
    switch (filter) {
      case 'Not Work Related Apps':
        filterOption = SoftwareConcreteState.notRelated;
        break;
      case 'Approved Apps':
        filterOption = SoftwareConcreteState.approved;
        break;
      case 'Rejected Apps':
        filterOption = SoftwareConcreteState.rejected;
        break;
      case 'Waiting Approval':
        filterOption = SoftwareConcreteState.waiting;
        break;
    }

    setState(() {
      curFilter = filter;
      ref.read(logStateNotifierProvider.notifier).setFilterOption(filterOption);
    });
  }

  handleSelectDate(List<DateTime> dates) {
    log(dates.toString());
    setState(() {
      selectedDates = dates;
    });
    ref.read(logStateNotifierProvider.notifier).getActivty(dates.first);
  }
}
