import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/phone_padding.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/sample_text_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:protasks/core/themes/app_theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePageview extends StatelessWidget {
  const CreatePageview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        PhonePadding(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryTextColor.withOpacity(0.1),
                      const Color(0x1A808080),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SampleTextPlaceholder(
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SampleTextPlaceholder(
                          width: 200,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  SampleTextPlaceholder(
                                    width: 24,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  SampleTextPlaceholder(
                                    width: 100,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  SampleTextPlaceholder(
                                    width: 24,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  SampleTextPlaceholder(
                                    width: 60,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        AbsorbPointer(
                          child: Transform.scale(
                            scale: 2.5,
                            child: MyCircularCheckBox(
                              value: true,
                              onChanged: (_) {},
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: context.watch<KeyboardVisibilityWithFocusNodeCubit>().isVisible
              ? SizedBox()
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      AutoSizeText.rich(
                        TextSpan(
                          text: 'Create\n',
                          children: [
                            TextSpan(
                              text: 'your tasks with ',
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: Strings.primaryFontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'ease',
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: Strings.primaryFontFamily,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontSize: 54,
                            fontFamily: Strings.primaryFontFamily,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
