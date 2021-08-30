import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/data/models/recursion_interval.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_date_time_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_reminder_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_repeat_cubit.dart';
import 'package:protasks/logic/extra_extensions.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentRepeatWidget extends StatelessWidget {
  const CurrentRepeatWidget({
    Key? key,
    required this.buttonIconSize,
  }) : super(key: key);

  final double buttonIconSize;

  @override
  Widget build(BuildContext repeatContext) {
    return BlocBuilder<CurrentRepeatCubit, CurrentRepeatState>(
      builder: (context, state) {
        print("state.isAcceptable : ${state.isAcceptable}");
        return MyButton(
          icon: Icon(
            Icons.repeat,
            size: buttonIconSize,
            color: const Color(0xFFFFFFFF),
          ),
          isError: !state.isAcceptable,
          label: state.recursionInterval != RecursionInterval.zero
              ? Text(
                  "Every ${state.recursionInterval.recursionIntervalToString}${state.recursionTill.toUtc() != DateTimeExtensions.invalid ? ' till ${ExtraFunctions.findAbsoluteDateOnly(dateTime: state.recursionTill)}' : ''}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
          onTap: () async {
            final CurrentRepeatState _currentRepeatState =
                repeatContext.read<CurrentRepeatCubit>().state;

            final FixedExtentScrollController _yearsScrollController =
                FixedExtentScrollController(
              initialItem: _currentRepeatState.recursionInterval.years,
            );

            final FixedExtentScrollController _monthsScrollController =
                FixedExtentScrollController(
              initialItem: _currentRepeatState.recursionInterval.months,
            );

            final FixedExtentScrollController _daysScrollController =
                FixedExtentScrollController(
              initialItem: _currentRepeatState.recursionInterval.days,
            );

            final FixedExtentScrollController _hoursScrollController =
                FixedExtentScrollController(
              initialItem: _currentRepeatState.recursionInterval.hours,
            );

            final FixedExtentScrollController _minutesScrollController =
                FixedExtentScrollController(
              initialItem: _currentRepeatState.recursionInterval.minutes == 0
                  ? 0
                  : _currentRepeatState.recursionInterval.minutes - 29,
            );

            final CurrentRepeatState? newCurrentRepeatState =
                await showDialog<CurrentRepeatState?>(
              context: repeatContext,
              builder: (context) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => CurrentRepeatCubit(
                        currentReminderCubit:
                            repeatContext.read<CurrentReminderCubit>(),
                      )..updateRepeatState(
                          recursionInterval:
                              _currentRepeatState.recursionInterval,
                          recursionTill: _currentRepeatState.recursionTill,
                        ),
                    ),
                  ],
                  child: Dialog(
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: BlocBuilder<CurrentRepeatCubit, CurrentRepeatState>(
                      builder: (context, state) {
                        CurrentRepeatState _currentRepeatState =
                            context.read<CurrentRepeatCubit>().state;

                        RecursionInterval _currentRecursionInterval =
                            _currentRepeatState.recursionInterval;

                        DateTime _recursionTill =
                            _currentRepeatState.recursionTill;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'REPEAT INTERVAL',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 100,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const AutoSizeText(
                                                  'YR.',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      CupertinoPicker.builder(
                                                    itemExtent: 30,
                                                    scrollController:
                                                        _yearsScrollController,
                                                    onSelectedItemChanged:
                                                        (value) {
                                                      print("YEARS: ");
                                                      context
                                                          .read<
                                                              CurrentRepeatCubit>()
                                                          .updateRepeatState(
                                                            recursionInterval:
                                                                RecursionInterval(
                                                              years: value,
                                                              months:
                                                                  _currentRecursionInterval
                                                                      .months,
                                                              days:
                                                                  _currentRecursionInterval
                                                                      .days,
                                                              hours:
                                                                  _currentRecursionInterval
                                                                      .hours,
                                                              minutes:
                                                                  _currentRecursionInterval
                                                                      .minutes,
                                                            ),
                                                          );
                                                    },
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Center(
                                                      child: Text(
                                                        "${index + 0}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    childCount: 2,
                                                    diameterRatio: 1,
                                                    offAxisFraction: -1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const AutoSizeText(
                                                  'MOS',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      CupertinoPicker.builder(
                                                    itemExtent: 30,
                                                    scrollController:
                                                        _monthsScrollController,
                                                    onSelectedItemChanged:
                                                        (value) {
                                                      print("MONTHS: ");
                                                      context
                                                          .read<
                                                              CurrentRepeatCubit>()
                                                          .updateRepeatState(
                                                            recursionInterval:
                                                                RecursionInterval(
                                                              years:
                                                                  _currentRecursionInterval
                                                                      .years,
                                                              months: value,
                                                              days:
                                                                  _currentRecursionInterval
                                                                      .days,
                                                              hours:
                                                                  _currentRecursionInterval
                                                                      .hours,
                                                              minutes:
                                                                  _currentRecursionInterval
                                                                      .minutes,
                                                            ),
                                                          );
                                                    },
                                                    offAxisFraction: -0.5,
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Center(
                                                      child: Text(
                                                        '${index + 0}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    childCount: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const AutoSizeText(
                                                  'DAYS',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      CupertinoPicker.builder(
                                                    itemExtent: 30,
                                                    scrollController:
                                                        _daysScrollController,
                                                    offAxisFraction: 0,
                                                    onSelectedItemChanged:
                                                        (value) {
                                                      print("DAYS: ");
                                                      context
                                                          .read<
                                                              CurrentRepeatCubit>()
                                                          .updateRepeatState(
                                                            recursionInterval:
                                                                RecursionInterval(
                                                              years:
                                                                  _currentRecursionInterval
                                                                      .years,
                                                              months:
                                                                  _currentRecursionInterval
                                                                      .months,
                                                              days: value,
                                                              hours:
                                                                  _currentRecursionInterval
                                                                      .hours,
                                                              minutes:
                                                                  _currentRecursionInterval
                                                                      .minutes,
                                                            ),
                                                          );
                                                    },
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Center(
                                                      child: Text(
                                                        '$index',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    childCount: 31,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const AutoSizeText(
                                                  'HRS',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      CupertinoPicker.builder(
                                                    itemExtent: 30,
                                                    scrollController:
                                                        _hoursScrollController,
                                                    offAxisFraction: 0.5,
                                                    onSelectedItemChanged:
                                                        (value) {
                                                      print("HOURS: ");
                                                      context
                                                          .read<
                                                              CurrentRepeatCubit>()
                                                          .updateRepeatState(
                                                            recursionInterval:
                                                                RecursionInterval(
                                                              years:
                                                                  _currentRecursionInterval
                                                                      .years,
                                                              months:
                                                                  _currentRecursionInterval
                                                                      .months,
                                                              days:
                                                                  _currentRecursionInterval
                                                                      .days,
                                                              hours: value,
                                                              minutes:
                                                                  _currentRecursionInterval
                                                                      .minutes,
                                                            ),
                                                          );
                                                    },
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Center(
                                                      child: Text(
                                                        '$index',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    childCount: 24,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const AutoSizeText(
                                                  'MINS',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Expanded(
                                                  child:
                                                      CupertinoPicker.builder(
                                                    itemExtent: 30,
                                                    scrollController:
                                                        _minutesScrollController,
                                                    offAxisFraction: 1,
                                                    onSelectedItemChanged:
                                                        (value) {
                                                      print("MIN: ");
                                                      context
                                                          .read<
                                                              CurrentRepeatCubit>()
                                                          .updateRepeatState(
                                                            recursionInterval:
                                                                RecursionInterval(
                                                              years:
                                                                  _currentRecursionInterval
                                                                      .years,
                                                              months:
                                                                  _currentRecursionInterval
                                                                      .months,
                                                              days:
                                                                  _currentRecursionInterval
                                                                      .days,
                                                              hours:
                                                                  _currentRecursionInterval
                                                                      .hours,
                                                              minutes: value ==
                                                                      0
                                                                  ? 0
                                                                  : value + 29,
                                                            ),
                                                          );
                                                    },
                                                    itemBuilder:
                                                        (context, index) =>
                                                            Center(
                                                      child: Text(
                                                        "${index == 0 ? 0 : index + 29}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    childCount: 31,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        (_currentRecursionInterval !=
                                                RecursionInterval.zero)
                                            ? "This task will repeat every ${_currentRecursionInterval.recursionIntervalToString}"
                                            : "This task won't repeat",
                                        style: TextStyle(
                                          fontFamily:
                                              Strings.secondaryFontFamily,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!state.isAcceptable)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  color: Theme.of(context)
                                      .primaryTextColor
                                      .withOpacity(0.1),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CAUTION",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: Strings.primaryFontFamily,
                                        ),
                                      ),
                                      Text(
                                        "Repeat interval is smaller than reminder",
                                        style: TextStyle(
                                          fontFamily:
                                              Strings.secondaryFontFamily,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'REPEAT TILL (OPTIONAL)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton.icon(
                                            icon: Icon(
                                              Icons.date_range,
                                              size: buttonIconSize,
                                            ),
                                            label: Text(
                                              ExtraFunctions
                                                      .findAbsoluteDateOnly(
                                                    dateTime: _recursionTill,
                                                  ) ??
                                                  "Not Defined",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            onPressed: () async {
                                              DateTime currentTime =
                                                  DateTime.now();
                                              DateTime taskDate = repeatContext
                                                  .read<CurrentDateTimeCubit>()
                                                  .state
                                                  .currentDateOnly;
                                              DateTime? _probableRecursionTill =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate: _recursionTill
                                                                  .toUtc() ==
                                                              DateTimeExtensions
                                                                  .invalid
                                                          ? taskDate
                                                          : _recursionTill,
                                                      firstDate: taskDate,
                                                      lastDate: DateTime(
                                                        currentTime.year + 10,
                                                        currentTime.month,
                                                      ).subtract(
                                                          Duration(days: 1)),
                                                      builder:
                                                          (context, child) {
                                                        return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .copyWith(
                                                                      primary: Theme.of(
                                                                              context)
                                                                          .accentColor,
                                                                      brightness:
                                                                          Brightness
                                                                              .light,
                                                                    ),
                                                            dialogBackgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .backgroundColor,
                                                          ),
                                                          child: child!,
                                                        );
                                                      });
                                              if (_probableRecursionTill !=
                                                  null) {
                                                context
                                                    .read<CurrentRepeatCubit>()
                                                    .updateRepeatState(
                                                      recursionInterval:
                                                          _currentRecursionInterval,
                                                      recursionTill:
                                                          _probableRecursionTill,
                                                    );
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context
                                                .read<CurrentRepeatCubit>()
                                                .updateRepeatState(
                                                  recursionTill:
                                                      DateTimeExtensions
                                                          .invalid,
                                                );
                                          },
                                          child: Text('Clear'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(
                                                CurrentRepeatState(
                                                  recursionInterval:
                                                      RecursionInterval.zero,
                                                  recursionTill:
                                                      DateTimeExtensions
                                                          .invalid,
                                                  remindTimer:
                                                      state.remindTimer,
                                                  taskTime: state.taskTime,
                                                ),
                                              );
                                            },
                                            child: Text("Delete")),
                                        Spacer(),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(_currentRepeatState);
                                            },
                                            child: Text("OK")),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel")),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
            if (newCurrentRepeatState != null) {
              DateTime? correctRecursionTill;
              if (newCurrentRepeatState.recursionTill.toUtc() !=
                  DateTimeExtensions.invalid) {
                correctRecursionTill =
                    newCurrentRepeatState.recursionTill.add(Duration(
                  hours: 23,
                  minutes: 59,
                ));
              }
              repeatContext.read<CurrentRepeatCubit>().updateRepeatState(
                    recursionInterval: newCurrentRepeatState.recursionInterval,
                    recursionTill: correctRecursionTill ??
                        newCurrentRepeatState.recursionTill,
                  );
            }
          },
        );
      },
    );
  }
}
