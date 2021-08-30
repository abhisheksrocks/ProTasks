import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/top_pageviews/welcome_pageview/widgets/sample_task_card.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/phone_padding.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomePageview extends StatelessWidget {
  const WelcomePageview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        PhonePadding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SampleTaskCard(),
              const Opacity(
                opacity: 0.6,
                child: const SampleTaskCard(
                  checked: false,
                ),
              ),
              const Opacity(
                opacity: 0.2,
                child: const SampleTaskCard(
                  checked: false,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const AutoSizeText(
                        'PROTASKS',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 56,
                          fontFamily: Strings.primaryFontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      AutoSizeText(
                        'To Dos, simplified.',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: Strings.primaryFontFamily,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
