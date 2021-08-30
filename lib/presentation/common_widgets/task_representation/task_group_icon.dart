import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/data/data_providers/groups_dao.dart';
import 'package:flutter/material.dart';

class TaskGroupIcon extends StatelessWidget {
  final String groupId;
  final double fontSize;
  const TaskGroupIcon({
    Key? key,
    required this.groupId,
    this.fontSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(groupId),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Theme.of(context).taskGroupColor,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.3,
        vertical: fontSize * 0.2,
      ),
      child: FutureBuilder<String?>(
        future: GroupsDao().findGroupNameById(groupId),
        builder: (context, snapshot) {
          // print("GroupID: $groupId");
          // print("Group future: ${snapshot.data}");
          String stringToShow = GroupsDao.groupIdToName[groupId] ?? 'Loading⌛';
          String? receivedData = snapshot.data;
          if (snapshot.connectionState == ConnectionState.done) {
            if (receivedData == null) {
              stringToShow = '<INVALID>';
            } else {
              stringToShow = receivedData;
            }
          }
          return Text(
            stringToShow,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          );
          // return SizedBox();
          // return Text(
          //   'Loading⌛',
          //   style: TextStyle(
          //     fontSize: 10,
          //     color: Theme.of(context).secondaryTextColor,
          //     fontWeight: FontWeight.w400,
          //   ),
          // );
        },
      ),
    );
  }
}
