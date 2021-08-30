import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/top_pageviews/collaborate_pageview/widgets/sample_assignees_card.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/phone_padding.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class CollaboratePageview extends StatelessWidget {
  const CollaboratePageview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        PhonePadding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SampleAssigneesCard(
                isChecked: false,
              ),
              Opacity(
                opacity: 0.7,
                child: SampleAssigneesCard(
                  isChecked: true,
                ),
              ),
              Opacity(
                opacity: 0.4,
                child: SampleAssigneesCard(
                  isChecked: false,
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
                          text: 'Collaborate\n',
                          children: [
                            TextSpan(
                              text: 'with others in a ',
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: Strings.primaryFontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'breeze',
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
