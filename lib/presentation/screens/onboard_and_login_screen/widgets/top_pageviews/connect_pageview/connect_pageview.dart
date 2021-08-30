import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/phone_padding.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/sample_text_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protasks/core/themes/app_theme.dart';

class ConnectPageview extends StatelessWidget {
  const ConnectPageview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        PhonePadding(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
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
                              width: 50,
                              height: 20,
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.04),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).accentColor.withOpacity(0.20),
                          const Color(0x332B3380),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SampleTextPlaceholder(
                          width: double.infinity,
                          color: Theme.of(context).accentColor.withOpacity(0.2),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SampleTextPlaceholder(
                          width: 50,
                          height: 20,
                          color: Theme.of(context).accentColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ),
                ],
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
                          text: 'Connect\n',
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
