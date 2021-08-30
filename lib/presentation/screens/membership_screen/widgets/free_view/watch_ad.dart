import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/cubit/root_cubits/ads_handler_cubit.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:protasks/presentation/common_widgets/task_representation/my_circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class WatchAd extends StatelessWidget {
  const WatchAd({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        List<Widget> rowItems = [];
        int currentStep = context.watch<AdsHandlerCubit>().state.currentStep;
        for (var i = 0; i < FirebaseRConfigHandler.freeToProAds; i++) {
          rowItems.add(
            Expanded(
              child: Transform.scale(
                scale: 2,
                child: AbsorbPointer(
                  absorbing: true,
                  child: MyCircularCheckBox(
                    value: i < currentStep,
                    onChanged: (value) {},
                  ),
                ),
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 12,
            ),
            Row(
              children: rowItems,
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    "${FirebaseRConfigHandler.freeToProAds - currentStep} Ads away from PRO",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: Strings.primaryFontFamily,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            (FirebaseRConfigHandler.freeToProAds - currentStep) <= 0
                ? TextButton(
                    onPressed: () {
                      context.read<AdsHandlerCubit>().checkAndMakePro();
                    },
                    style: Theme.of(context).greenTextButtonStyle,
                    child: Text(
                      'Activate PRO',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Strings.primaryFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () async {
                      if (!await InternetConnectionChecker().hasConnection) {
                        Fluttertoast.showToast(msg: "This needs internet");
                        return;
                      }
                      context.read<AdsHandlerCubit>().showFreeToProRewardedAd();
                    },
                    style: Theme.of(context).myTextButtonStyle,
                    child: Text(
                      'Next Ad',
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Strings.primaryFontFamily,
                        fontSize: 20,
                      ),
                    ),
                  ),
            SizedBox(
              height: 12,
            ),
          ],
        );
      },
    );
  }
}
