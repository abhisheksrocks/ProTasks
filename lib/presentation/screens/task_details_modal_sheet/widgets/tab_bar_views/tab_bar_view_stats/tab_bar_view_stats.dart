import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/presentation/common_widgets/detail_maker.dart';
import 'package:protasks/presentation/common_widgets/detail_title.dart';
import 'package:protasks/presentation/common_widgets/detail_value.dart';
import 'package:protasks/presentation/screens/task_details_modal_sheet/widgets/user_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/data/models/task.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/task_details_modal_sheet_specific/task_details_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';

class TabBarViewStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This statement is only if the chat screen has keyboard showing and it moves to this screen
    // I noticed that it doesn't [dispose()], and hence the keyboard remains on the screen.
    // FocusScope.of(context).requestFocus(new FocusNode());
    //
    // Using context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard() since I
    // moved KeyboardVisibilityWithFocusNodeCubit to the whole modalBottomSheet, instead of
    // TabBarViewChat specifically(where it was originally) so I don't think
    // FocusScope.of(context).requestFocus(new FocusNode()) will be required.
    context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard();
    return BlocBuilder<SingleTaskDetailsCubit, SingleTaskDetailsState>(
      builder: (context, state) {
        if (state is SingleTaskDetailsLoaded) {
          Task currentTask = state.currentTask;

          return ListView(
            physics: const BouncingScrollPhysics(
              parent: const AlwaysScrollableScrollPhysics(),
            ),
            children: [
              Wrap(
                runSpacing: 8,
                spacing: 8,
                children: [
                  const SizedBox(
                    height: 10,
                    width: 1,
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'UPDATED ON'),
                        Builder(
                          builder: (context) {
                            String stringToShow =
                                ExtraFunctions.findAbsoluteDateAndTime(
                                        time: currentTask.modifiedOn) ??
                                    'Not Defined';
                            return DetailValue(stringToShow: stringToShow);
                          },
                        ),
                      ],
                    ),
                    secondWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'UPDATED BY'),
                        UserNameWidget(userUID: currentTask.modifiedBy),
                      ],
                    ),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'CREATED ON'),
                        Builder(
                          builder: (context) {
                            String stringToShow =
                                ExtraFunctions.findAbsoluteDateAndTime(
                                        time: currentTask.createdOn) ??
                                    'Not Defined';
                            return DetailValue(stringToShow: stringToShow);
                          },
                        ),
                      ],
                    ),
                    secondWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'CREATED BY'),
                        UserNameWidget(userUID: currentTask.createdBy),
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Divider(
                      thickness: 2,
                    ),
                  ),
                  DetailMaker(
                    firstWidget: const DetailTitle(title: 'FOR NERDS'),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'TASK ID'),
                        DetailValue(stringToShow: currentTask.id),
                      ],
                    ),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'PARENT TASK ID'),
                        DetailValue(stringToShow: currentTask.parentTaskId),
                      ],
                    ),
                  ),
                  DetailMaker(
                    firstWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DetailTitle(title: 'GROUP ID'),
                        DetailValue(stringToShow: currentTask.groupId),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          );
        }
        return const Center(
          child: const CircularProgressIndicator(),
        );
      },
    );
  }
}
