import 'package:auto_size_text/auto_size_text.dart';
import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/core/themes/app_theme.dart';
import 'package:protasks/presentation/router/app_router.dart';
import 'package:protasks/presentation/screens/membership_screen/widgets/free_view/watch_ad.dart';
import 'package:flutter/material.dart';

class FreeFirstPageview extends StatelessWidget {
  const FreeFirstPageview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        WatchAd(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              'Experience the',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  'PRO',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.check,
                  size: 40,
                  color: Colors.green,
                ),
              ],
            ),
            AutoSizeText(
              'without the',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  'PAY',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.clear,
                  size: 40,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.plansScreen);
              },
              style: Theme.of(context).textButtonThemeStyle,
              child: Text(
                'Compare Plans',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: Strings.primaryFontFamily,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
