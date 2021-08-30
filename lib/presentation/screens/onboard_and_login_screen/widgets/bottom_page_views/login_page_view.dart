import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/auth_handler.dart';
import 'package:protasks/logic/cubit/root_cubits/login_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/status_nav_bar_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/logic/my_navigator.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({
    Key? key,
    this.functionToExecute,
  }) : super(key: key);
  final void Function()? functionToExecute;

  @override
  Widget build(BuildContext context) {
    context.read<KeyboardVisibilityWithFocusNodeCubit>().dismissKeyboard();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: context.read<StatusNavBarCubit>().state.themeMode ==
                      ThemeMode.dark
                  ? Theme.of(context).accentColor
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: functionToExecute,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.77,
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: const Icon(
                          Icons.mail,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 2,
                          ),
                          child: const AutoSizeText(
                            'Continue with email',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: Strings.primaryFontFamily,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: const Opacity(
                          opacity: 0,
                          child: const Icon(
                            Icons.mail,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: () async {
                      if (await AuthHandler.signInWithGoogle() != null) {
                        Navigator.of(MyNavigator.context!)
                            .pushNamedAndRemoveUntil(
                                AppRouter.dashboard, (route) => true);
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.77,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              top: 2,
                              bottom: 4,
                              right: 4,
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 2,
                              ),
                              child: const AutoSizeText(
                                'Continue with Google',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: Strings.primaryFontFamily,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: const Opacity(
                              opacity: 0,
                              child: const Icon(
                                FontAwesomeIcons.google,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        InkWell(
          onTap: () {
            if (context.read<LoginCubit>().state.currentLoginState ==
                CurrentLoginState.choseNotToLogIn) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.dashboard,
                (route) => true,
              );
            } else {
              context.read<LoginCubit>().userChoseNotToLogin();
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontFamily: Strings.primaryFontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
