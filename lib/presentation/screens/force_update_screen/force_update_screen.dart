import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/logic/firebase_rconfig_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:protasks/logic/package_info_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryTextColor,
      body: Center(
        child: AlertDialog(
          title: Text("APP OUTDATED"),
          content: Text(
              "To continue using the app, please update to atleast v${FirebaseRConfigHandler.leastRecommendedVersion} or the latest version from playstore.\n\nAny unsynced data is saved locally."),
          backgroundColor: Theme.of(context).backgroundColor,
          actions: [
            TextButton(
              onPressed: () async {
                String url =
                    "https://play.google.com/store/apps/details?id=${PackageInfoHandler.packageName}";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  Fluttertoast.showToast(
                    msg: "Unable to open! Please update manually.",
                  );
                }
              },
              child: Text('Open Playstore'),
            ),
          ],
        ),
      ),
    );
  }
}
