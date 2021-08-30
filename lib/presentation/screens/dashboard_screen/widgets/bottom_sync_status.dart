import 'package:protasks/core/constants/enums.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/cubit/root_cubits/sync_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class BottomSyncStatus extends StatelessWidget {
  const BottomSyncStatus({Key? key}) : super(key: key);

  Widget switchToNothingMaker(Widget initial) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, snapshot) {
        Widget widget = snapshot.connectionState == ConnectionState.done
            ? SizedBox()
            : initial;
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1),
                end: Offset(0, 0),
              ).animate(animation),
              child: child,
            );
          },
          child: widget,
        );
      },
    );
  }

  Widget childBuilder(BuildContext context, CurrentSyncState currentSyncState) {
    switch (currentSyncState) {
      case CurrentSyncState.inProgress:
        return IntrinsicHeight(
          child: Stack(
            key: ValueKey("inProgress"),
            alignment: AlignmentDirectional.center,
            children: [
              Shimmer.fromColors(
                child: Container(
                  width: double.infinity,
                  color: Colors.black,
                ),
                baseColor: Theme.of(context).accentColor,
                highlightColor: Theme.of(context).backgroundColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'UPDATING',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      case CurrentSyncState.deviceOffline:
        return switchToNothingMaker(
          Container(
            width: double.infinity,
            color: Theme.of(context).lowPriorityBannerColor,
            padding: EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            child: Text(
              "DEVICE OFFLINE",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      case CurrentSyncState.waiting:
        return switchToNothingMaker(
          Container(
            width: double.infinity,
            color: Theme.of(context).lowPriorityBannerColor,
            padding: EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            child: Text(
              "NEXT UPDATE QUEUED",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      case CurrentSyncState.complete:
        return switchToNothingMaker(
          Container(
            width: double.infinity,
            color: Theme.of(context).highPriorityBannerColor,
            padding: EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            child: Text(
              "UPDATING REALTIME",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      case CurrentSyncState.serverError:
        return switchToNothingMaker(
          Container(
            width: double.infinity,
            color: Theme.of(context).overdueBannerColor,
            padding: EdgeInsets.symmetric(vertical: 2),
            alignment: Alignment.center,
            child: Text(
              "SERVER ERROR",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      buildWhen: (previous, current) {
        return previous.currentSyncState != current.currentSyncState;
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1),
                end: Offset(0, 0),
              ).animate(animation),
              child: child,
            );
          },
          child: childBuilder(context, state.currentSyncState),
        );
      },
    );
  }
}
