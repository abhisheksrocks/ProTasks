import 'package:protasks/presentation/common_widgets/dialog_related/my_will_pop_scope/confirmation_dialog.dart';
import 'package:flutter/material.dart';

class MyWillPopScope extends StatelessWidget {
  const MyWillPopScope({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // try {
        //   context
        //       .read<KeyboardVisibilityWithFocusNodeCubit>()
        //       .dismissKeyboard();
        // } catch (exception) {
        //   print("No KeyboardVisibilityWithFocusNodeCubit provided");
        // }
        bool? confirm = await showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(),
        );
        if (confirm == true) {
          return true;
        }
        return false;
      },
      child: child,
    );
  }
}
