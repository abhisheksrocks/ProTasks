import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:protasks/logic/cubit/root_cubits/media_query_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:flutter/material.dart';

class MySliverAppBar extends StatefulWidget {
  const MySliverAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
  }) : super(key: key);

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  _MySliverAppBarState createState() => _MySliverAppBarState();
}

class _MySliverAppBarState extends State<MySliverAppBar> {
  @override
  void didChangeDependencies() {
    print("Checking for MediaQueryCubit Update");
    EdgeInsets _mediaQueryPadding = MediaQuery.of(context).padding;
    EdgeInsets _cubitPadding = context.read<MediaQueryCubit>().state.padding;

    Size _mediaQuerySize = MediaQuery.of(context).size;
    Size _cubitSize = context.read<MediaQueryCubit>().state.size;
    if ((_cubitPadding != _mediaQueryPadding) ||
        (_cubitSize != _mediaQuerySize)) {
      print("Updating MediaQueryCubit");
      context.read<MediaQueryCubit>().updateValues(
            padding: _mediaQueryPadding,
            size: _mediaQuerySize,
          );
    } else {
      print("MediaQueryCubit update not required");
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 4,
      key: widget.key,
      title: Text(
        widget.title,
        style: TextStyle(
          fontFamily: Strings.primaryFontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      brightness: Brightness.dark, //This is set the status bar icon colors
      // brightness: AppTheme
      //     .brightnessSetByCubit, //This is set the status bar icon colors
      floating: true,

      leading: widget.leading ??
          IconButton(
            icon: Icon(
              Icons.menu,
              size: 30,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
      leadingWidth: 30,

      actions: widget.actions ??
          [
            // IconButton(
            //   icon: Icon(
            //     Icons.search,
            //     size: 30,
            //   ),
            //   onPressed: () async {
            //     List<PushNotification> activeSchedules =
            //         await AwesomeNotifications().listScheduledNotifications();

            //     for (PushNotification schedule in activeSchedules) {
            //       debugPrint('pending notification: ['
            //           'id: ${schedule.content!.id}, '
            //           'title: ${schedule.content!.titleWithoutHtml}, '
            //           'schedule: ${schedule.schedule.toString()}'
            //           ']');
            //     }
            //   },
            // ),
          ],
    );
  }
}
