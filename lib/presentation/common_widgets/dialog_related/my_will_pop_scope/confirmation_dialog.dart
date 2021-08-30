import 'package:protasks/core/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    Key? key,
    this.title = 'Are you sure?',
    this.content = 'This will discard your changes(if any)',
    this.actionText = 'Discard',
  }) : super(key: key);

  final String title;
  final String content;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return AlertDialog(
          // title: Text('Discard changes?'),
          title: Text(title),
          content: Text(content),
          // content: Text('Discard changes?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Cancel')),
            TextButton(
                style: Theme.of(context).errorTextButtonStyle,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop(true);
                },
                child: Text(actionText)),
          ],
        );
      },
      // ),
    );
  }
}
