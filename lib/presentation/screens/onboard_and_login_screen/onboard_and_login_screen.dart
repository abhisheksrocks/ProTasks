import 'package:protasks/logic/cubit/pageview_animation_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/loading_cubit.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/bottom_page_views/enter_email_page_view/enter_email_page_view.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/bottom_page_views/login_page_view.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/top_pageviews/collaborate_pageview/collaborate_pageview.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/top_pageviews/connect_pageview/connect_pageview.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/top_pageviews/create_pageview/create_pageview.dart';
import 'package:protasks/presentation/screens/onboard_and_login_screen/widgets/top_pageviews/welcome_pageview/welcome_pageview.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protasks/core/themes/app_theme.dart';

class OnboardAndLoginScreenProvider extends StatelessWidget {
  const OnboardAndLoginScreenProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PageviewAnimationCubit>(
          create: (context) => PageviewAnimationCubit(),
        ),
        BlocProvider<KeyboardVisibilityWithFocusNodeCubit>(
          create: (context) => KeyboardVisibilityWithFocusNodeCubit(),
        ),
        BlocProvider<LoadingCubit>(
          create: (context) => LoadingCubit(),
        ),
      ],
      child: OnboardAndLoginScreen(),
    );
  }
}

class OnboardAndLoginScreen extends StatefulWidget {
  const OnboardAndLoginScreen({Key? key}) : super(key: key);

  @override
  _OnboardAndLoginScreenState createState() => _OnboardAndLoginScreenState();
}

class _OnboardAndLoginScreenState extends State<OnboardAndLoginScreen> {
  final PageController _topPageController = PageController(
    initialPage: 0,
  );

  final PageController _bottomPageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    context.read<PageviewAnimationCubit>().initializeController(
          newPageController: _topPageController,
          numberOfPages: 4,
        );
    super.initState();
  }

  @override
  void dispose() {
    _topPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                      // context.read<MediaQueryCubit>().state.size.height * 0.5,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      // context.read<MediaQueryCubit>().state.size.width * 0.9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          //  const Color(0x24FFFFFF),
                          Theme.of(context).primaryTextColor.withOpacity(0.25),
                          // const Color(0x00545454),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .secondaryTextColor
                            .withOpacity(0.3),
                        // color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onLongPressStart: (_) {
                    print("onLongPressStart");
                    context.read<PageviewAnimationCubit>().changePausedState();
                  },
                  onLongPressEnd: (_) {
                    print("onLongPressEnd");
                    context.read<PageviewAnimationCubit>().changePausedState();
                  },
                  child: AbsorbPointer(
                    absorbing: true,
                    child: PageView(
                      physics: const BouncingScrollPhysics(),
                      controller: _topPageController,
                      children: [
                        WelcomePageview(),
                        CreatePageview(),
                        ConnectPageview(),
                        CollaboratePageview(),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: Theme.of(context).primaryColor,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.33,
                    width: double.infinity,
                    child: PageView(
                      controller: _bottomPageController,
                      children: [
                        LoginPageView(
                          functionToExecute: () {
                            _bottomPageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                        EnterEmailPageViewProvider(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (context.watch<LoadingCubit>().state.isLoading)
              Container(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
