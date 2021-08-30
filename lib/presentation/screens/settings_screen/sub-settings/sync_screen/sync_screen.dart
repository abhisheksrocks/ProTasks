import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:protasks/logic/extra_functions.dart';
import 'package:protasks/presentation/common_widgets/my_sliver_appbar.dart';
import 'package:protasks/presentation/common_widgets/detail_maker.dart';
import 'package:protasks/presentation/common_widgets/detail_title.dart';
import 'package:protasks/presentation/common_widgets/detail_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:protasks/core/themes/app_theme.dart';

import 'package:protasks/logic/extra_extensions.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({Key? key}) : super(key: key);

  String lastSyncTime(DateTime dateTimeToCheck) {
    if (ExtraFunctions.findTodayTomorrowOrYesterday(dateTimeToCheck,
            checkForTomorrow: false, checkForYesterday: false) ==
        null) {
      return ExtraFunctions.findRelativeDateWithTime(
              dateAndTime: dateTimeToCheck, isBy: false) ??
          'Not Updated Yet';
    }
    DateTime currentTime = DateTime.now();
    final String prefix = '<';
    var inWords = ExtraFunctions.findRemindTimeInWords(
      taskTime: currentTime,
      taskRemindTimer: currentTime.difference(dateTimeToCheck),
      prefix: prefix,
      suffix: null,
    )?.capitalize;
    if (inWords == '$prefix Null') {
      inWords = null;
    }
    if (inWords != null) {
      inWords += ' ago';
    }
    return inWords ?? 'Just Now';
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
    return "In ${hours}h:${minutes}m:${seconds}s";
  }

  Container makeTag(BuildContext context, CurrentSyncState currentSyncState) {
    String stringToSet;
    Color textColor;
    Color bannerColor;
    switch (currentSyncState) {
      case CurrentSyncState.initialized:
        stringToSet = "INITIALIZED";
        textColor = Colors.white;
        bannerColor = Theme.of(context).lowPriorityBannerColor;
        break;
      case CurrentSyncState.complete:
        stringToSet = "UPDATING REALTIME";
        textColor = Colors.white;
        bannerColor = Theme.of(context).highPriorityBannerColor;
        break;
      case CurrentSyncState.waiting:
        stringToSet = "NEXT UPDATE QUEUED";
        textColor = Colors.white;
        bannerColor = Theme.of(context).lowPriorityBannerColor;
        break;
      case CurrentSyncState.inProgress:
        stringToSet = "IN PROGRESS";
        textColor = Colors.white;
        bannerColor = Theme.of(context).accentColor;
        break;
      case CurrentSyncState.deviceOffline:
        stringToSet = "DEVICE OFFLINE";
        textColor = Colors.white;
        bannerColor = Theme.of(context).overdueBannerColor;
        break;
      case CurrentSyncState.serverError:
        stringToSet = "SERVER ERROR";
        textColor = Colors.white;
        bannerColor = Theme.of(context).overdueBannerColor;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        stringToSet,
        style: TextStyle(
          fontSize: 16,
          fontFamily: Strings.secondaryFontFamily,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MySliverAppBar(
            title: 'Sync Information',
            actions: [],
            leading: BackButton(),
          ),
          BlocBuilder<SyncCubit, SyncState>(
            builder: (context, state) {
              return SliverToBoxAdapter(
                child: StreamBuilder(
                    stream: Stream.periodic(Duration(seconds: 1)),
                    builder: (_, snapshot) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 16,
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          DetailMaker(
                            firstWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DetailTitle(title: 'LAST GROUP UPDATE'),
                                DetailValue(
                                  stringToShow:
                                      lastSyncTime(state.lastGroupSyncTime),
                                ),
                              ],
                            ),
                            secondWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DetailTitle(title: 'LAST TASK UPDATE'),
                                DetailValue(
                                  stringToShow:
                                      lastSyncTime(state.lastTaskSyncTime),
                                ),
                              ],
                            ),
                          ),
                          DetailMaker(
                            firstWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DetailTitle(title: 'LAST CHAT UPDATE'),
                                DetailValue(
                                  stringToShow:
                                      lastSyncTime(state.lastChatSyncTime),
                                ),
                              ],
                            ),
                            secondWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DetailTitle(title: 'NEXT UPDATE'),
                                DetailValue(
                                    stringToShow: countdownTimer(
                                  context.read<SyncCubit>().nextUpdateTime,
                                )),
                              ],
                            ),
                          ),
                          DetailMaker(
                            firstWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DetailTitle(title: 'CURRENT STATUS'),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child:
                                      makeTag(context, state.currentSyncState),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              );
            },
          ),
        ],
      ),
    );
  }
}
