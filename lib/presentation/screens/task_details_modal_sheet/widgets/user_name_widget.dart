import 'package:flutter/material.dart';
import 'package:protasks/core/constants/strings.dart';

import 'package:protasks/data/data_providers/users_dao.dart';
import 'package:protasks/logic/firebase_auth_functions.dart';

import 'package:protasks/presentation/common_widgets/detail_value.dart';

class UserNameWidget extends StatelessWidget {
  final String userUID;
  final TextStyle? textStyle;
  final double? textScaleFactor;
  const UserNameWidget({
    Key? key,
    required this.userUID,
    this.textScaleFactor,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UsersDao().getUserNamesFromIDs([userUID]),
      builder: (context, snapshot) {
        String stringToShow = UsersDao.usersIdToName[userUID] ?? "Loading⌛";
        if (userUID ==
            (FirebaseAuthFunctions.getCurrentUser?.uid ??
                Strings.defaultUserUID)) {
          stringToShow = "You";
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (UsersDao.usersIdToName[userUID] == null) {
            stringToShow = '<INVALID USER>';
          }
        }
        return DetailValue(
          stringToShow: stringToShow,
          textScaleFactor: textScaleFactor,
          textStyle: textStyle,
        );
      },
    );
  }
}
