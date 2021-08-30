import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_date_time_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentDateWidget extends StatelessWidget {
  const CurrentDateWidget({
    Key? key,
    required this.buttonIconSize,
  }) : super(key: key);

  final double buttonIconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentDateTimeCubit, CurrentDateTime>(
      builder: (context, state) {
        return MyButton(
          icon: Icon(
            Icons.date_range,
            size: buttonIconSize,
            color: const Color(0xFFFFFFFF),
          ),
          label: Text(
            ExtraFunctions.findRelativeDateOnly(
              date: state.currentDateOnly,
              checkForToday: true,
              checkForTomorrow: true,
              checkForYesterday: false,
            ),
            style: TextStyle(
              color: const Color(0xFFFFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
          isError: !state.isAcceptable,
          onTap: () async {
            DateTime currentTime = DateTime.now();
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: state.currentDateOnly.isBefore(currentTime)
                    ? currentTime
                    : state.currentDateOnly,
                firstDate: currentTime,
                lastDate: DateTime(
                  currentTime.year + 10,
                  currentTime.month,
                ).subtract(Duration(days: 1)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: Theme.of(context).accentColor,
                            brightness: Brightness.light,
                          ),
                      dialogBackgroundColor: Theme.of(context).backgroundColor,
                    ),
                    child: child!,
                  );
                });
            context.read<CurrentDateTimeCubit>().changeDate(
                  newDate: pickedDate,
                  isForced: true,
                );
          },
        );
      },
    );
  }
}
