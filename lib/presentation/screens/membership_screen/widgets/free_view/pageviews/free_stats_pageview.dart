import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/free_view/watch_ad.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/not_enough_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FreeStatsPageview extends StatelessWidget {
  const FreeStatsPageview({Key? key}) : super(key: key);

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
    return Padding(
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
          context.watch<AdsHandlerCubit>().state.adsShown < 11
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      'Ads Seen',
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      '${context.read<AdsHandlerCubit>().state.adsShown}',
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
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
                          color: Theme.of(context).overdueBannerColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      'Potential time lost',
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
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
                                      '${adsToTimeLost(context.read<AdsHandlerCubit>().state.adsShown)}',
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
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
          WatchAd(),
        ],
      ),
    );
  }
}
