import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:protasks/logic/cubit/root_cubits/premium_checker_cubit.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/free_view/pageview_container.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/not_enough_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({Key? key}) : super(key: key);

  String addZeroIfSingleDigit(int toProcess) {
    return toProcess >= 0 && toProcess < 10 ? "0$toProcess" : "$toProcess";
  }

  String countdownTimer(DateTime? dateTimeToCheck) {
    if (dateTimeToCheck == null) {
      return "NOT SET";
    }
    Duration diffDuration = dateTimeToCheck.difference(DateTime.now());

    int hours = diffDuration.inHours;
    int remainingSeconds = diffDuration.inSeconds - hours * 3600;
    int minutes = (remainingSeconds / 60).truncate();
    int seconds = remainingSeconds % 60;
    return "${addZeroIfSingleDigit(hours)} : ${addZeroIfSingleDigit(minutes)} : ${addZeroIfSingleDigit(seconds)}";
  }

  String adsToTimeLost(int adsCount) {
    String stringToReturn = '';
    Duration duration = Duration(minutes: 1, seconds: 54) * adsCount;
    int hours = duration.inHours;
    int minutes = duration.inMinutes - hours * 60;
    if (hours > 0) {
      stringToReturn += "${hours}h ";
    }
    stringToReturn += "${minutes}m";
    return stringToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumCheckerCubit, PremiumCheckerState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  color:
                      state.currentPremiumState == CurrentPremiumState.freeUser
                          ? Theme.of(context).overdueBannerColor
                          : Theme.of(context).accentColor,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        context.read<MediaQueryCubit>().state.size.width * 0.2,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              "YOU ARE",
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: Strings.primaryFontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                      state.currentPremiumState == CurrentPremiumState.freeUser
                          ? AutoSizeText(
                              "MISSING\nOUT!",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 100,
                                fontFamily: Strings.primaryFontFamily,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).backgroundColor,
                              ),
                            )
                          : Shimmer.fromColors(
                              baseColor: Theme.of(context).backgroundColor,
                              highlightColor:
                                  Theme.of(context).highPriorityBannerColor,
                              period: Duration(
                                seconds: 5,
                              ),
                              child: AutoSizeText(
                                'PRO',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 100,
                                  fontFamily: Strings.primaryFontFamily,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: state.currentPremiumState == CurrentPremiumState.freeUser
                    ? PageviewContainerProvider()
                    : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                AutoSizeText(
                                  'STATS',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            context
                                        .watch<AdsHandlerCubit>()
                                        .state
                                        .adsNotShownBecausePro <
                                    11
                                ? NotEnoughData()
                                : Expanded(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: Theme.of(context)
                                                .primaryTextColor
                                                .withOpacity(0.2),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        'Ads Avoided',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        '${context.read<AdsHandlerCubit>().state.adsNotShownBecausePro}',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: 48,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color:
                                                Theme.of(context).accentColor,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        'Time Saved',
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        adsToTimeLost(context
                                                            .read<
                                                                AdsHandlerCubit>()
                                                            .state
                                                            .adsNotShownBecausePro),
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: 48,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(
                              height: 12,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        "Membership ends in",
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: Strings.primaryFontFamily,
                                          fontSize: 20,
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StreamBuilder(
                                          stream: Stream.periodic(
                                              Duration(seconds: 1)),
                                          builder: (context, snapshot) {
                                            return AutoSizeText(
                                              countdownTimer(state.premiumTill),
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    Strings.primaryFontFamily,
                                                fontSize: 48,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AppRouter.plansScreen);
                              },
                              style: Theme.of(context).textButtonThemeStyle,
                              child: Text('Compare Plans'),
                            ),
                          ],
                        ),
                      ),
              )
            ],
          ),
        );
      },
    );
  }
}
