import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_date_time_cubit.dart';
import 'package:protasks/logic/cubit/modal_sheet_cubits/add_new_task_modal_sheet_specific/current_reminder_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/core/themes/app_theme.dart';

class CurrentReminderWidget extends StatelessWidget {
  CurrentReminderWidget({
    Key? key,
    required this.buttonIconSize,
    required this.taskTime,
  }) : super(key: key);

  final double buttonIconSize;
  final DateTime taskTime;

  MyButton createButton({
    required String labelText,
    required String textValueToPass,
    required TextEditingController textEditingController,
    required CurrentReminderCubit currentReminderCubit,
  }) {
    return MyButton(
      label: Text(
        labelText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        ExtraFunctions.updateTextEditingControllerValue(
          textEditingController: textEditingController,
          newValue: textValueToPass,
        );
        currentReminderCubit.changeReminder(
          textFieldValue: textEditingController.text,
          currentReminderOption:
              currentReminderCubit.state.currentReminderOption,
        );
      },
    );
  }

  List<MyButton> buttonsToShow({
    required TextEditingController textEditingController,
    required CurrentReminderCubit currentReminderCubit,
  }) {
    switch (currentReminderCubit.state.currentReminderOption) {
      case CurrentReminderOption.mins:
        return [
          createButton(
            labelText: '10 mins early',
            textValueToPass: '10',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '15 mins early',
            textValueToPass: '15',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '30 mins early',
            textValueToPass: '30',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '45 mins early',
            textValueToPass: '45',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '1h 30 mins early',
            textValueToPass: '90',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '2h 30 mins early',
            textValueToPass: '150',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
        ];
      case CurrentReminderOption.hrs:
        return [
          createButton(
            labelText: '1 hr early',
            textValueToPass: '1',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '2 hrs early',
            textValueToPass: '2',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '3 hrs early',
            textValueToPass: '3',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '6 hrs early',
            textValueToPass: '6',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '12 hrs early',
            textValueToPass: '12',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '1d 12 hrs early',
            textValueToPass: '36',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
        ];
      case CurrentReminderOption.days:
        return [
          createButton(
            labelText: '1 day early',
            textValueToPass: '1',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '2 days early',
            textValueToPass: '2',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '5 days early',
            textValueToPass: '5',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '10 days early',
            textValueToPass: '10',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '15 days early',
            textValueToPass: '15',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
        ];
      case CurrentReminderOption.weeks:
        return [
          createButton(
            labelText: '1 week early',
            textValueToPass: '1',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '2 weeks early',
            textValueToPass: '2',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '3 weeks early',
            textValueToPass: '3',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
          createButton(
            labelText: '4 weeks early',
            textValueToPass: '4',
            textEditingController: textEditingController,
            currentReminderCubit: currentReminderCubit,
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext reminderContext) {
    return BlocBuilder<CurrentReminderCubit, CurrentReminderState>(
      builder: (context, state) => FutureBuilder<bool?>(
          future: ExtraFunctions.updateAtThisDateTime(
            dateTime: state.getRemindTime,
          ),
          builder: (context, snapshot) {
            if (snapshot.data != null &&
                snapshot.connectionState == ConnectionState.done) {
              context.read<CurrentReminderCubit>().refreshState();
            }
            return MyButton(
              icon: Icon(
                Icons.timer,
                size: buttonIconSize,
                color: const Color(0xFFFFFFFF),
              ),
              isError: !state.isAcceptable,
              label: state.remindTimer == Duration.zero
                  ? null
                  : Text(
                      ExtraFunctions.findRemindTimeInWords(
                        taskTime: state.taskTime,
                        taskRemindTimer: state.remindTimer,
                        prefix: null,
                      )!,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
              onTap: () async {
                CurrentReminderState? _currentReminderState = await showDialog(
                  context: reminderContext,
                  builder: (context) {
                    TextEditingController _textEditingController =
                        TextEditingController();

                    int _currentTextFieldValue = reminderContext
                        .read<CurrentReminderCubit>()
                        .state
                        .textFieldValue;

                    if (_currentTextFieldValue != 0) {
                      _textEditingController.text =
                          _currentTextFieldValue.toString();
                    } else {
                      _textEditingController.text = '10';
                    }

                    final BorderRadius _dialogBorderRadius =
                        BorderRadius.circular(4);

                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => TextEditingControllerCubit()
                            ..beginFetching(
                              newTextEditingController: _textEditingController,
                              newStateEveryCharacter: true,
                            ),
                        ),
                        BlocProvider(
                          create: (context) => CurrentReminderCubit(
                            currentDateTimeCubit:
                                reminderContext.read<CurrentDateTimeCubit>(),
                          )..changeReminder(
                              textFieldValue: reminderContext
                                  .read<CurrentReminderCubit>()
                                  .state
                                  .textFieldValue
                                  .toString(),
                              currentReminderOption: reminderContext
                                  .read<CurrentReminderCubit>()
                                  .state
                                  .currentReminderOption,
                            ),
                        ),
                      ],
                      child: Dialog(
                        backgroundColor: Theme.of(context).backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: _dialogBorderRadius,
                        ),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Container(
                            child: BlocBuilder<TextEditingControllerCubit,
                                TextEditingControllerState>(
                              builder: (context, state) {
                                CurrentReminderCubit _currentReminderCubit =
                                    context.read<CurrentReminderCubit>();

                                if (_currentReminderCubit
                                        .state.remindTimer.inDays >
                                    28) {
                                  switch (_currentReminderCubit
                                      .state.currentReminderOption) {
                                    case CurrentReminderOption.weeks:
                                      ExtraFunctions
                                          .updateTextEditingControllerValue(
                                        textEditingController:
                                            _textEditingController,
                                        newValue: '4',
                                      );

                                      break;
                                    case CurrentReminderOption.days:
                                      ExtraFunctions
                                          .updateTextEditingControllerValue(
                                        textEditingController:
                                            _textEditingController,
                                        newValue: '28',
                                      );
                                      break;
                                    case CurrentReminderOption.hrs:
                                      ExtraFunctions
                                          .updateTextEditingControllerValue(
                                        textEditingController:
                                            _textEditingController,
                                        newValue: '672',
                                      );
                                      break;
                                    case CurrentReminderOption.mins:
                                      ExtraFunctions
                                          .updateTextEditingControllerValue(
                                        textEditingController:
                                            _textEditingController,
                                        newValue: '40320',
                                      );
                                      break;
                                    default:
                                      ExtraFunctions
                                          .updateTextEditingControllerValue(
                                        textEditingController:
                                            _textEditingController,
                                        newValue: '403200',
                                      );
                                  }
                                }

                                _currentReminderCubit.changeReminder(
                                  textFieldValue:
                                      _textEditingController.text.isEmpty
                                          ? '0'
                                          : _textEditingController.text,
                                  currentReminderOption: _currentReminderCubit
                                      .state.currentReminderOption,
                                );

                                context.watch<CurrentReminderCubit>();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'REMINDER',
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .chatTextFieldColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller:
                                                  _textEditingController,
                                              style: TextStyle(
                                                fontSize: 20,
                                              ),
                                              decoration:
                                                  InputDecoration.collapsed(
                                                hintText: 'Enter duration...',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Center(
                                            child: Wrap(
                                              spacing: 8,
                                              children: [
                                                MyButton(
                                                  label: Text(
                                                    'Mins',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    _currentReminderCubit
                                                        .changeReminder(
                                                      textFieldValue:
                                                          _textEditingController
                                                              .text,
                                                      currentReminderOption:
                                                          CurrentReminderOption
                                                              .mins,
                                                    );
                                                  },
                                                  isToggleOn: _currentReminderCubit
                                                          .state
                                                          .currentReminderOption ==
                                                      CurrentReminderOption
                                                          .mins,
                                                ),
                                                MyButton(
                                                  label: Text(
                                                    'Hrs',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    _currentReminderCubit
                                                        .changeReminder(
                                                      textFieldValue:
                                                          _textEditingController
                                                              .text,
                                                      currentReminderOption:
                                                          CurrentReminderOption
                                                              .hrs,
                                                    );
                                                  },
                                                  isToggleOn: _currentReminderCubit
                                                          .state
                                                          .currentReminderOption ==
                                                      CurrentReminderOption.hrs,
                                                ),
                                                MyButton(
                                                  label: Text(
                                                    'Days',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    _currentReminderCubit
                                                        .changeReminder(
                                                      textFieldValue:
                                                          _textEditingController
                                                              .text,
                                                      currentReminderOption:
                                                          CurrentReminderOption
                                                              .days,
                                                    );
                                                  },
                                                  isToggleOn: _currentReminderCubit
                                                          .state
                                                          .currentReminderOption ==
                                                      CurrentReminderOption
                                                          .days,
                                                ),
                                                MyButton(
                                                  label: Text(
                                                    'Weeks',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    _currentReminderCubit
                                                        .changeReminder(
                                                      textFieldValue:
                                                          _textEditingController
                                                              .text,
                                                      currentReminderOption:
                                                          CurrentReminderOption
                                                              .weeks,
                                                    );
                                                  },
                                                  isToggleOn: _currentReminderCubit
                                                          .state
                                                          .currentReminderOption ==
                                                      CurrentReminderOption
                                                          .weeks,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 24,
                                          ),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              ...buttonsToShow(
                                                currentReminderCubit:
                                                    _currentReminderCubit,
                                                textEditingController:
                                                    _textEditingController,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!(_textEditingController.text.isEmpty ||
                                        _textEditingController.text == '0'))
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        color: _currentReminderCubit
                                                .state.isAcceptable
                                            ? null
                                            : Theme.of(context)
                                                .primaryTextColor
                                                .withOpacity(0.1),
                                        child: _currentReminderCubit
                                                .state.isAcceptable
                                            ? Text(
                                                'You will be notified at ${ExtraFunctions.findRelativeDateWithTime(dateAndTime: _currentReminderCubit.state.getRemindTime, isBy: false)}',
                                                style: TextStyle(
                                                  fontFamily: Strings
                                                      .secondaryFontFamily,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "CAUTION",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: Strings
                                                          .primaryFontFamily,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${ExtraFunctions.findRemindTimeInWords(
                                                      taskTime:
                                                          _currentReminderCubit
                                                              .state.taskTime,
                                                      taskRemindTimer:
                                                          _currentReminderCubit
                                                              .state
                                                              .remindTimer,
                                                      prefix: null,
                                                      suffix: 'early',
                                                    )} .i.e. ${ExtraFunctions.findRelativeDateWithTime(dateAndTime: _currentReminderCubit.state.getRemindTime, isBy: false)} has already passed.",
                                                    style: TextStyle(
                                                      fontFamily: Strings
                                                          .secondaryFontFamily,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(
                                                CurrentReminderState(
                                                  currentReminderOption:
                                                      _currentReminderCubit
                                                          .state
                                                          .currentReminderOption,
                                                  remindTimer: Duration.zero,
                                                  taskTime:
                                                      _currentReminderCubit
                                                          .state.taskTime,
                                                ),
                                              );
                                            },
                                            child: Text('Clear'),
                                          ),
                                          Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(
                                                  _currentReminderCubit.state);
                                            },
                                            child: Text('Okay'),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
                if (_currentReminderState != null) {
                  reminderContext.read<CurrentReminderCubit>().changeReminder(
                        textFieldValue:
                            _currentReminderState.textFieldValue.toString(),
                        currentReminderOption:
                            _currentReminderState.currentReminderOption,
                      );
                }
              },
            );
          }),
    );
  }
}
