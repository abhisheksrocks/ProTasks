import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_date_time_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CurrentTimeWidget extends StatelessWidget {
  CurrentTimeWidget({
    Key? key,
    required this.buttonIconSize,
  }) : super(key: key);

  final double buttonIconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentDateTimeCubit, CurrentDateTime>(
      builder: (context, state) {
        return FutureBuilder<bool?>(
            future: ExtraFunctions.updateAtThisDateTime(
                dateTime: state.finalTaskTime),
            builder: (context, snapshot) {
              // Reupdates the state when the currentTime reaches newTask Time
              // in case when the new task time is not saved before

              if (snapshot.data != null &&
                  snapshot.connectionState == ConnectionState.done) {
                context.read<CurrentDateTimeCubit>().refreshData();
              }
              return MyButton(
                icon: Icon(
                  Icons.access_time,
                  size: buttonIconSize,
                  color: const Color(0xFFFFFFFF),
                ),
                label: Text(
                  "${DateFormat("HH:mm a").format(DateTime(0, 0, 0, state.currentTimeOnly.hour, state.currentTimeOnly.minute))}",
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                isError: !state.isAcceptable,
                onTap: () async {
                  TimeOfDay currentTime = TimeOfDay.now();
                  int newMinute = 15 * (currentTime.minute ~/ 15) + 15;
                  if (newMinute >= 60) {
                    currentTime = currentTime.replacing(
                      hour:
                          currentTime.hour + 1 >= 24 ? 0 : currentTime.hour + 1,
                      minute: 0,
                    );
                  } else {
                    currentTime = currentTime.replacing(minute: newMinute);
                  }
                  print("newMinute: $newMinute");

                  // TODO: Implement a logic so that ki time change depends on date as well
                  TimeOfDay? newTimeOfDay = await showTimePicker(
                    context: context,
                    initialTime: state.isTimeForced
                        ? state.currentTimeOnly
                        // : TimeOfDay.now(),
                        : currentTime,
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: Theme.of(context).accentColor,
                            ),
                        // timePickerTheme: Theme.of(context).timePickerTheme,
                      ),
                      child: child!,
                    ),
                  );
                  print(
                      "${newTimeOfDay?.hour}:${newTimeOfDay?.minute} ${newTimeOfDay?.period}");

                  context.read<CurrentDateTimeCubit>().changeTime(
                        newTimeOfDay: newTimeOfDay,
                        isForced: true,
                      );
                },
              );
            });
      },
    );
  }
}
