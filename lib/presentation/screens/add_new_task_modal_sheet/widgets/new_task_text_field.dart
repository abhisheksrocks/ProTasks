import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class NewTaskTextField extends StatefulWidget {
  const NewTaskTextField({
    Key? key,
    this.defaultText,
  }) : super(key: key);

  final String? defaultText;

  @override
  _NewTaskTextFieldState createState() => _NewTaskTextFieldState();
}

class _NewTaskTextFieldState extends State<NewTaskTextField> {
  late TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      scrollPhysics: BouncingScrollPhysics(),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      // minLines: 1,
      maxLines: null,
      style: TextStyle(
        fontFamily: Strings.secondaryFontFamily,
        fontSize: 24,
      ),
      decoration: InputDecoration.collapsed(
        hintText: "Add a task",
        hintStyle: TextStyle(
          fontFamily: Strings.secondaryFontFamily,
          fontSize: 24,
        ),
      ),
    );
  }

  @override
  void initState() {
    controller = TextEditingController(
      text: widget.defaultText,
    );
    context
        .read<TextEditingControllerCubit>()
        .beginFetching(newTextEditingController: controller);
    super.initState();
  }
}
