import 'package:protasks/core/constants/strings.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/keyboard_visibility_with_focus_node_cubit.dart';
import 'package:protasks/logic/cubit/very_objective_sepecific_cubits/text_editing_controller_cubit.dart';
import 'package:flutter/material.dart';

import 'package:protasks/logic/extra_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnterEmailTextField extends StatefulWidget {
  const EnterEmailTextField({Key? key}) : super(key: key);

  @override
  _EnterEmailTextFieldState createState() => _EnterEmailTextFieldState();
}

class _EnterEmailTextFieldState extends State<EnterEmailTextField> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    context
        .read<TextEditingControllerCubit>()
        .beginFetching(newTextEditingController: _textEditingController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.disabled,
      controller: _textEditingController,
      validator: (input) {
        if (input != null) {
          return input.isValidEmail ? null : 'Enter a valid email';
        }
      },
      focusNode:
          context.read<KeyboardVisibilityWithFocusNodeCubit>().getFocusNode,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        counter: const SizedBox(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        prefixIcon: Icon(
          Icons.email,
          color: Colors.white,
        ),
        fillColor: Colors.pink,
        focusColor: Colors.orange,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          gapPadding: 0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          gapPadding: 0,
        ),
        labelText: '  E-mail  ',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        hintText: "Your email",
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).errorColor,
          ),
          gapPadding: 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white,
          ),
          gapPadding: 0,
        ),
        labelStyle: TextStyle(
          fontFamily: Strings.primaryFontFamily,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        hintStyle: TextStyle(
          fontFamily: Strings.primaryFontFamily,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
