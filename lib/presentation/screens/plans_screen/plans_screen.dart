import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/screens/plans_screen/widgets/subscription_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlansScreen extends StatelessWidget {
  PlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: PageView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            color: Theme.of(context).backgroundColor,
            margin: EdgeInsets.symmetric(
              vertical: screenHeight * 0.1,
              horizontal: screenWidth * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.03,
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Wrap(
                        runSpacing: 12,
                        spacing: 12,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Free User',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(),
                          SubscriptionFeature(
                            title: 'No need to Pay!',
                          ),
                          SubscriptionFeature(
                            title: 'Access to all the features!',
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                          SubscriptionFeature(
                            title: 'Cloud Backup!',
                          ),
                          SubscriptionFeature(
                            title: 'Supports Collaboration!',
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                          SubscriptionFeature(
                            isAdvantage: false,
                            title: 'Casual Ads',
                          ),
                          SubscriptionFeature(
                            isAdvantage: false,
                            title:
                                'Chat sync every 15 minutes\n(Send / Receive)',
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                          SubscriptionFeature(
                            isAdvantage: false,
                            title:
                                "Task sync every 15 minutes\n(Upload / Download)",
                          ),
                          SubscriptionFeature(
                            isAdvantage: false,
                            title:
                                "Group sync every 15 minutes\n(Upload / Download)",
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      context
                                  .read<PremiumCheckerCubit>()
                                  .state
                                  .currentPremiumState ==
                              CurrentPremiumState.freeUser
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppRouter.dashboard,
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Continue as Free',
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            margin: EdgeInsets.symmetric(
              vertical: screenHeight * 0.1,
              horizontal: screenWidth * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.025,
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Wrap(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        runSpacing: 12,
                        spacing: 12,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.2),
                                      ),
                                      child: Text(
                                        "PRO",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' User',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(),
                          SubscriptionFeature(
                            title: 'No need to Pay!',
                          ),
                          SubscriptionFeature(
                            title: 'Access to all the features!',
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                          SubscriptionFeature(
                            title: 'Cloud Backup!',
                          ),
                          SubscriptionFeature(
                            title: 'Supports Collaboration!',
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                          SubscriptionFeature(
                            title: 'Complete Ad-Free Experience!',
                          ),
                          SubscriptionFeature(
                            title: "Real-Time chat!",
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                          SubscriptionFeature(
                            title: "Real-Time task updates!",
                          ),
                          SubscriptionFeature(
                            title: "Real-Time group updates!",
                            textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextColor
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      context
                                  .read<PremiumCheckerCubit>()
                                  .state
                                  .currentPremiumState ==
                              CurrentPremiumState.freeUser
                          ? TextButton(
                              onPressed: () {
                                // Navigator.of(context)
                                //     .pushReplacementNamed(AppRouter.freeToPro);
                                Navigator.of(context).pop();
                              },
                              style: Theme.of(context).myTextButtonStyle,
                              child: Text(
                                'Switch to PRO',
                              ),
                            )
                          : TextButton(
                              onPressed: () {
                                // Navigator.of(context).pushNamedAndRemoveUntil(
                                //     AppRouter.freeToPro, (route) => true);
                                Navigator.of(context).pop();
                              },
                              style: Theme.of(context).myTextButtonStyle,
                              child: Text(
                                'You are PRO!',
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
