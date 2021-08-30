import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class NewGroupTextField extends StatefulWidget {
  const NewGroupTextField({
    Key? key,
  }) : super(key: key);

  @override
  _NewGroupTextFieldState createState() => _NewGroupTextFieldState();
}

class _NewGroupTextFieldState extends State<NewGroupTextField> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    context.read<TextEditingControllerCubit>().beginFetching(
          newTextEditingController: controller,
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      scrollPhysics: BouncingScrollPhysics(),
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      maxLines: null,
      style: TextStyle(
        fontFamily: Strings.secondaryFontFamily,
        fontSize: 24,
      ),
      maxLength: 25,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      decoration: InputDecoration.collapsed(
        hintText: "Group name",
        hintStyle: TextStyle(
          fontFamily: Strings.secondaryFontFamily,
          fontSize: 24,
        ),
      ),
    );
  }
}
