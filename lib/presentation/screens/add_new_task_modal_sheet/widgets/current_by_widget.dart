import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_by_cubit.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentByWidget extends StatelessWidget {
  const CurrentByWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyButton(
      label: BlocBuilder<CurrentByCubit, CurrentBy>(
        builder: (context, state) {
          return Text(
            state.isBy ? "by" : "at",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFFFFF),
            ),
          );
        },
      ),
      onTap: () {
        context.read<CurrentByCubit>().changeIsBy();
      },
    );
  }
}
